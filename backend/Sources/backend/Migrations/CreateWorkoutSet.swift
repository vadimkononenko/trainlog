import Fluent

struct CreateWorkoutSet: AsyncMigration {
    /// Creates the workout sets table.
    ///
    /// - Parameter database: The database that runs the migration.
    func prepare(on database: any Database) async throws {
        try await database.schema(WorkoutSet.schema)
            .id()
            .field("session_exercise_id", .uuid, .required, .references(WorkoutSessionExercise.schema, .id, onDelete: .cascade))
            .field("position", .int, .required)
            .field("reps", .int)
            .field("weight", .double)
            .field("duration_seconds", .int)
            .field("distance_meters", .double)
            .field("is_completed", .bool, .required)
            .field("notes", .string)
            .create()
    }

    /// Drops the workout sets table.
    ///
    /// - Parameter database: The database that reverts the migration.
    func revert(on database: any Database) async throws {
        try await database.schema(WorkoutSet.schema).delete()
    }
}

