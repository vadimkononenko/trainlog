import Foundation
import Fluent

struct ExercisePageResult: Sendable {
    let exercises: [Exercise]
    let total: Int
}

protocol ExerciseRepository: Sendable {
    func listVisible(
        for userID: UUID,
        page: Int,
        limit: Int,
        searchQuery: String?,
        category: ExerciseCategory?,
        equipment: ExerciseEquipment?,
        on database: any Database
    ) async throws -> ExercisePageResult
    func findVisible(id: UUID, for userID: UUID, on database: any Database) async throws -> Exercise?
    func findUserOwned(id: UUID, for userID: UUID, on database: any Database) async throws -> Exercise?
    func listChangedVisible(for userID: UUID, since: Date?, on database: any Database) async throws -> [Exercise]
    func create(_ exercise: Exercise, on database: any Database) async throws -> Exercise
    func update(_ exercise: Exercise, on database: any Database) async throws -> Exercise
    func delete(_ exercise: Exercise, on database: any Database) async throws
}

struct DefaultExerciseRepository: ExerciseRepository {
    /// Lists exercises visible to a user with pagination and filters.
    ///
    /// - Parameters:
    ///   - userID: The authenticated user identifier.
    ///   - page: The requested page number.
    ///   - limit: The number of items per page.
    ///   - searchQuery: The optional name search query.
    ///   - category: The optional category filter.
    ///   - equipment: The optional equipment filter.
    ///   - database: The database used for lookup.
    /// - Returns: The page of matching exercises and total count.
    func listVisible(
        for userID: UUID,
        page: Int,
        limit: Int,
        searchQuery: String?,
        category: ExerciseCategory?,
        equipment: ExerciseEquipment?,
        on database: any Database
    ) async throws -> ExercisePageResult {
        let total = try await makeVisibleQuery(
            for: userID,
            searchQuery: searchQuery,
            category: category,
            equipment: equipment,
            on: database
        ).count()

        let exercises = try await makeVisibleQuery(
            for: userID,
            searchQuery: searchQuery,
            category: category,
            equipment: equipment,
            on: database
        )
        .sort(\.$name, .ascending)
        .range(((page - 1) * limit)..<(page * limit))
        .all()

        return ExercisePageResult(exercises: exercises, total: total)
    }

    /// Finds an exercise visible to a user.
    ///
    /// - Parameters:
    ///   - id: The exercise identifier.
    ///   - userID: The authenticated user identifier.
    ///   - database: The database used for lookup.
    /// - Returns: The matching visible exercise, if one exists.
    func findVisible(id: UUID, for userID: UUID, on database: any Database) async throws -> Exercise? {
        try await makeVisibleQuery(for: userID, searchQuery: nil, category: nil, equipment: nil, on: database)
            .filter(\.$id == id)
            .first()
    }

    /// Finds a user-owned exercise.
    ///
    /// - Parameters:
    ///   - id: The exercise identifier.
    ///   - userID: The authenticated user identifier.
    ///   - database: The database used for lookup.
    /// - Returns: The matching user-owned exercise, if one exists.
    func findUserOwned(id: UUID, for userID: UUID, on database: any Database) async throws -> Exercise? {
        try await Exercise.query(on: database)
            .filter(\.$id == id)
            .filter(\.$owner.$id == userID)
            .first()
    }

    /// Lists visible exercises changed since a timestamp for sync.
    ///
    /// - Parameters:
    ///   - userID: The authenticated user identifier.
    ///   - since: The lower bound timestamp. `nil` returns all visible exercises.
    ///   - database: The database used for lookup.
    /// - Returns: Changed visible exercises including soft-deleted user-owned exercises.
    func listChangedVisible(for userID: UUID, since: Date?, on database: any Database) async throws -> [Exercise] {
        let query = Exercise.query(on: database)
            .withDeleted()
            .group(.or) {
                $0.filter(\.$owner.$id == nil)
                    .filter(\.$owner.$id == userID)
            }
            .sort(\.$updatedAt, .ascending)

        if let since {
            query.group(.or) {
                $0.filter(\.$updatedAt >= since)
                    .filter(\.$deletedAt >= since)
            }
        }

        return try await query.all()
    }

    /// Creates an exercise record.
    ///
    /// - Parameters:
    ///   - exercise: The exercise model to create.
    ///   - database: The database used for persistence.
    /// - Returns: The created exercise model.
    func create(_ exercise: Exercise, on database: any Database) async throws -> Exercise {
        try await exercise.create(on: database)
        return exercise
    }

    /// Updates an exercise record.
    ///
    /// - Parameters:
    ///   - exercise: The exercise model to update.
    ///   - database: The database used for persistence.
    /// - Returns: The updated exercise model.
    func update(_ exercise: Exercise, on database: any Database) async throws -> Exercise {
        try await exercise.update(on: database)
        return exercise
    }

    /// Soft-deletes an exercise record.
    ///
    /// - Parameters:
    ///   - exercise: The exercise model to delete.
    ///   - database: The database used for persistence.
    func delete(_ exercise: Exercise, on database: any Database) async throws {
        try await exercise.delete(on: database)
    }

    /// Creates a base query for exercises visible to a user.
    ///
    /// - Parameters:
    ///   - userID: The authenticated user identifier.
    ///   - searchQuery: The optional name search query.
    ///   - category: The optional category filter.
    ///   - equipment: The optional equipment filter.
    ///   - database: The database used for lookup.
    /// - Returns: A configured exercise query builder.
    private func makeVisibleQuery(
        for userID: UUID,
        searchQuery: String?,
        category: ExerciseCategory?,
        equipment: ExerciseEquipment?,
        on database: any Database
    ) -> QueryBuilder<Exercise> {
        let query = Exercise.query(on: database)
            .group(.or) {
                $0.filter(\.$owner.$id == nil)
                    .filter(\.$owner.$id == userID)
            }

        if let searchQuery = normalizedSearchQuery(searchQuery) {
            query.filter(\.$name ~~ searchQuery)
        }

        if let category {
            query.filter(\.$category == category.rawValue)
        }

        if let equipment {
            query.filter(\.$equipment == equipment.rawValue)
        }

        return query
    }

    /// Normalizes a search query.
    ///
    /// - Parameter query: The raw search query.
    /// - Returns: The normalized query, or `nil` when empty.
    private func normalizedSearchQuery(_ query: String?) -> String? {
        let trimmedQuery = query?.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedQuery?.isEmpty == false ? trimmedQuery : nil
    }
}
