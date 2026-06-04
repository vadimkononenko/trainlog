import Fluent

struct CreateWorkoutSession: AsyncMigration {
    /// Creates the workout sessions table.
    ///
    /// - Parameter database: The database that runs the migration.
    func prepare(on database: any Database) async throws {
        try await database.schema(WorkoutSession.schema)
            .id()
            .field("owner_user_id", .uuid, .required, .references(User.schema, .id, onDelete: .cascade))
            .field("template_id", .uuid, .references(WorkoutTemplate.schema, .id, onDelete: .setNull))
            .field("started_at", .datetime, .required)
            .field("ended_at", .datetime)
            .field("notes", .string)
            .field("version", .int, .required)
            .field("created_at", .datetime, .required)
            .field("updated_at", .datetime, .required)
            .field("deleted_at", .datetime)
            .create()
    }

    /// Drops the workout sessions table.
    ///
    /// - Parameter database: The database that reverts the migration.
    func revert(on database: any Database) async throws {
        try await database.schema(WorkoutSession.schema).delete()
    }
}

