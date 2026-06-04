import Fluent

struct CreateWorkoutTemplate: AsyncMigration {
    /// Creates the workout templates table.
    ///
    /// - Parameter database: The database that runs the migration.
    func prepare(on database: any Database) async throws {
        try await database.schema(WorkoutTemplate.schema)
            .id()
            .field("owner_user_id", .uuid, .required, .references(User.schema, .id, onDelete: .cascade))
            .field("name", .string, .required)
            .field("notes", .string)
            .field("version", .int, .required)
            .field("created_at", .datetime, .required)
            .field("updated_at", .datetime, .required)
            .field("deleted_at", .datetime)
            .create()
    }

    /// Drops the workout templates table.
    ///
    /// - Parameter database: The database that reverts the migration.
    func revert(on database: any Database) async throws {
        try await database.schema(WorkoutTemplate.schema).delete()
    }
}

