import Fluent

struct CreateWorkoutSessionExercise: AsyncMigration {
    /// Creates the workout session exercises table.
    ///
    /// - Parameter database: The database that runs the migration.
    func prepare(on database: any Database) async throws {
        try await database.schema(WorkoutSessionExercise.schema)
            .id()
            .field("session_id", .uuid, .required, .references(WorkoutSession.schema, .id, onDelete: .cascade))
            .field("exercise_id", .uuid, .required, .references(Exercise.schema, .id, onDelete: .restrict))
            .field("position", .int, .required)
            .field("notes", .string)
            .create()
    }

    /// Drops the workout session exercises table.
    ///
    /// - Parameter database: The database that reverts the migration.
    func revert(on database: any Database) async throws {
        try await database.schema(WorkoutSessionExercise.schema).delete()
    }
}

