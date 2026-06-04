import Foundation
import Fluent

struct WorkoutSessionPageResult: Sendable {
    let sessions: [WorkoutSession]
    let total: Int
}

protocol WorkoutSessionRepository: Sendable {
    func list(for userID: UUID, page: Int, limit: Int, on database: any Database) async throws -> WorkoutSessionPageResult
    func listChanged(for userID: UUID, since: Date?, on database: any Database) async throws -> [WorkoutSession]
    func find(id: UUID, for userID: UUID, on database: any Database) async throws -> WorkoutSession?
    func create(_ session: WorkoutSession, on database: any Database) async throws -> WorkoutSession
    func update(_ session: WorkoutSession, on database: any Database) async throws -> WorkoutSession
    func replaceExercises(_ exercises: [(WorkoutSessionExercise, [WorkoutSet])], sessionID: UUID, on database: any Database) async throws
    func delete(_ session: WorkoutSession, on database: any Database) async throws
}

struct DefaultWorkoutSessionRepository: WorkoutSessionRepository {
    /// Lists workout sessions owned by a user.
    ///
    /// - Parameters:
    ///   - userID: The authenticated user identifier.
    ///   - page: The requested page number.
    ///   - limit: The number of items per page.
    ///   - database: The database used for lookup.
    /// - Returns: The page of matching sessions and total count.
    func list(
        for userID: UUID,
        page: Int,
        limit: Int,
        on database: any Database
    ) async throws -> WorkoutSessionPageResult {
        let total = try await makeOwnedQuery(for: userID, includeDeleted: false, on: database).count()
        let sessions = try await makeOwnedQuery(for: userID, includeDeleted: false, on: database)
            .sort(\.$startedAt, .descending)
            .range(((page - 1) * limit)..<(page * limit))
            .all()

        return WorkoutSessionPageResult(sessions: sessions, total: total)
    }

    /// Lists sessions changed since a timestamp for sync.
    ///
    /// - Parameters:
    ///   - userID: The authenticated user identifier.
    ///   - since: The lower bound timestamp. `nil` returns all sessions.
    ///   - database: The database used for lookup.
    /// - Returns: Changed sessions including soft-deleted sessions.
    func listChanged(for userID: UUID, since: Date?, on database: any Database) async throws -> [WorkoutSession] {
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

    /// Finds a user-owned session.
    ///
    /// - Parameters:
    ///   - id: The session identifier.
    ///   - userID: The authenticated user identifier.
    ///   - database: The database used for lookup.
    /// - Returns: The matching session, if one exists.
    func find(id: UUID, for userID: UUID, on database: any Database) async throws -> WorkoutSession? {
        try await makeOwnedQuery(for: userID, includeDeleted: false, on: database)
            .filter(\.$id == id)
            .first()
    }

    /// Creates a workout session.
    ///
    /// - Parameters:
    ///   - session: The session model to create.
    ///   - database: The database used for persistence.
    /// - Returns: The created session model.
    func create(_ session: WorkoutSession, on database: any Database) async throws -> WorkoutSession {
        try await session.create(on: database)
        return session
    }

    /// Updates a workout session.
    ///
    /// - Parameters:
    ///   - session: The session model to update.
    ///   - database: The database used for persistence.
    /// - Returns: The updated session model.
    func update(_ session: WorkoutSession, on database: any Database) async throws -> WorkoutSession {
        try await session.update(on: database)
        return session
    }

    /// Replaces all exercise and set rows for a session.
    ///
    /// - Parameters:
    ///   - exercises: The new session exercises and sets.
    ///   - sessionID: The session identifier.
    ///   - database: The database used for persistence.
    func replaceExercises(
        _ exercises: [(WorkoutSessionExercise, [WorkoutSet])],
        sessionID: UUID,
        on database: any Database
    ) async throws {
        try await WorkoutSessionExercise.query(on: database)
            .filter(\.$session.$id == sessionID)
            .delete()

        for (exercise, sets) in exercises {
            try await exercise.create(on: database)
            let sessionExerciseID = try exercise.requireID()
            for set in sets {
                set.$sessionExercise.id = sessionExerciseID
                try await set.create(on: database)
            }
        }
    }

    /// Soft-deletes a workout session.
    ///
    /// - Parameters:
    ///   - session: The session model to delete.
    ///   - database: The database used for persistence.
    func delete(_ session: WorkoutSession, on database: any Database) async throws {
        try await session.delete(on: database)
    }

    /// Creates a base query for sessions owned by a user.
    ///
    /// - Parameters:
    ///   - userID: The authenticated user identifier.
    ///   - includeDeleted: Whether soft-deleted rows should be returned.
    ///   - database: The database used for lookup.
    /// - Returns: A configured session query builder.
    private func makeOwnedQuery(
        for userID: UUID,
        includeDeleted: Bool,
        on database: any Database
    ) -> QueryBuilder<WorkoutSession> {
        let query = WorkoutSession.query(on: database)
            .filter(\.$owner.$id == userID)
            .with(\.$exercises) { exercise in
                exercise.with(\.$sets)
            }

        if includeDeleted {
            query.withDeleted()
        }

        return query
    }
}

