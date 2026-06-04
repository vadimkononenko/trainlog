import Foundation
import Fluent

struct WorkoutTemplatePageResult: Sendable {
    let templates: [WorkoutTemplate]
    let total: Int
}

protocol WorkoutTemplateRepository: Sendable {
    func list(for userID: UUID, page: Int, limit: Int, on database: any Database) async throws -> WorkoutTemplatePageResult
    func listChanged(for userID: UUID, since: Date?, on database: any Database) async throws -> [WorkoutTemplate]
    func find(id: UUID, for userID: UUID, on database: any Database) async throws -> WorkoutTemplate?
    func create(_ template: WorkoutTemplate, on database: any Database) async throws -> WorkoutTemplate
    func update(_ template: WorkoutTemplate, on database: any Database) async throws -> WorkoutTemplate
    func replaceExercises(_ exercises: [WorkoutTemplateExercise], templateID: UUID, on database: any Database) async throws
    func delete(_ template: WorkoutTemplate, on database: any Database) async throws
}

struct DefaultWorkoutTemplateRepository: WorkoutTemplateRepository {
    /// Lists workout templates owned by a user.
    ///
    /// - Parameters:
    ///   - userID: The authenticated user identifier.
    ///   - page: The requested page number.
    ///   - limit: The number of items per page.
    ///   - database: The database used for lookup.
    /// - Returns: The page of matching templates and total count.
    func list(
        for userID: UUID,
        page: Int,
        limit: Int,
        on database: any Database
    ) async throws -> WorkoutTemplatePageResult {
        let total = try await makeOwnedQuery(for: userID, includeDeleted: false, on: database).count()
        let templates = try await makeOwnedQuery(for: userID, includeDeleted: false, on: database)
            .sort(\.$updatedAt, .descending)
            .range(((page - 1) * limit)..<(page * limit))
            .all()

        return WorkoutTemplatePageResult(templates: templates, total: total)
    }

    /// Lists templates changed since a timestamp for sync.
    ///
    /// - Parameters:
    ///   - userID: The authenticated user identifier.
    ///   - since: The lower bound timestamp. `nil` returns all templates.
    ///   - database: The database used for lookup.
    /// - Returns: Changed templates including soft-deleted templates.
    func listChanged(for userID: UUID, since: Date?, on database: any Database) async throws -> [WorkoutTemplate] {
        let query = makeOwnedQuery(for: userID, includeDeleted: true, on: database)
            .sort(\.$updatedAt, .ascending)

        if let since {
            query.group(.or) {
                $0.filter(\.$updatedAt >= since)
                    .filter(\.$deletedAt >= since)
            }
        }

        return try await query.all()
    }

    /// Finds a user-owned template.
    ///
    /// - Parameters:
    ///   - id: The template identifier.
    ///   - userID: The authenticated user identifier.
    ///   - database: The database used for lookup.
    /// - Returns: The matching template, if one exists.
    func find(id: UUID, for userID: UUID, on database: any Database) async throws -> WorkoutTemplate? {
        try await makeOwnedQuery(for: userID, includeDeleted: false, on: database)
            .filter(\.$id == id)
            .first()
    }

    /// Creates a workout template.
    ///
    /// - Parameters:
    ///   - template: The template model to create.
    ///   - database: The database used for persistence.
    /// - Returns: The created template model.
    func create(_ template: WorkoutTemplate, on database: any Database) async throws -> WorkoutTemplate {
        try await template.create(on: database)
        return template
    }

    /// Updates a workout template.
    ///
    /// - Parameters:
    ///   - template: The template model to update.
    ///   - database: The database used for persistence.
    /// - Returns: The updated template model.
    func update(_ template: WorkoutTemplate, on database: any Database) async throws -> WorkoutTemplate {
        try await template.update(on: database)
        return template
    }

    /// Replaces all exercise rows for a template.
    ///
    /// - Parameters:
    ///   - exercises: The new template exercises.
    ///   - templateID: The template identifier.
    ///   - database: The database used for persistence.
    func replaceExercises(_ exercises: [WorkoutTemplateExercise], templateID: UUID, on database: any Database) async throws {
        try await WorkoutTemplateExercise.query(on: database)
            .filter(\.$template.$id == templateID)
            .delete()

        for exercise in exercises {
            try await exercise.create(on: database)
        }
    }

    /// Soft-deletes a workout template.
    ///
    /// - Parameters:
    ///   - template: The template model to delete.
    ///   - database: The database used for persistence.
    func delete(_ template: WorkoutTemplate, on database: any Database) async throws {
        try await template.delete(on: database)
    }

    /// Creates a base query for templates owned by a user.
    ///
    /// - Parameters:
    ///   - userID: The authenticated user identifier.
    ///   - includeDeleted: Whether soft-deleted rows should be returned.
    ///   - database: The database used for lookup.
    /// - Returns: A configured template query builder.
    private func makeOwnedQuery(
        for userID: UUID,
        includeDeleted: Bool,
        on database: any Database
    ) -> QueryBuilder<WorkoutTemplate> {
        let query = WorkoutTemplate.query(on: database)
            .filter(\.$owner.$id == userID)
            .with(\.$exercises)

        if includeDeleted {
            query.withDeleted()
        }

        return query
    }
}

