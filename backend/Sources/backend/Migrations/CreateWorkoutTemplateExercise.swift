import Fluent

struct CreateWorkoutTemplateExercise: AsyncMigration {
    /// Creates the workout template exercises table.
    ///
    /// - Parameter database: The database that runs the migration.
    func prepare(on database: any Database) async throws {
        try await database.schema(WorkoutTemplateExercise.schema)
            .id()
            .field("template_id", .uuid, .required, .references(WorkoutTemplate.schema, .id, onDelete: .cascade))
            .field("exercise_id", .uuid, .required, .references(Exercise.schema, .id, onDelete: .restrict))
            .field("position", .int, .required)
            .field("target_sets", .int)
            .field("target_reps", .int)
            .field("target_weight", .double)
            .field("rest_seconds", .int)
            .field("notes", .string)
            .create()
    }

    /// Drops the workout template exercises table.
    ///
    /// - Parameter database: The database that reverts the migration.
    func revert(on database: any Database) async throws {
        try await database.schema(WorkoutTemplateExercise.schema).delete()
    }
}

