import Fluent

struct CreateExercise: AsyncMigration {
    /// Creates the exercises table.
    ///
    /// - Parameter database: The database that runs the migration.
    func prepare(on database: any Database) async throws {
        try await database.schema(Exercise.schema)
            .id()
            .field("owner_user_id", .uuid, .references(User.schema, .id, onDelete: .cascade))
            .field("name", .string, .required)
            .field("category", .string, .required)
            .field("exercise_type", .string, .required)
            .field("equipment", .string, .required)
            .field("primary_muscles", .array(of: .string), .required)
            .field("instructions", .string, .required)
            .field("version", .int, .required)
            .field("created_at", .datetime, .required)
            .field("updated_at", .datetime, .required)
            .field("deleted_at", .datetime)
            .create()
    }

    /// Drops the exercises table.
    ///
    /// - Parameter database: The database that reverts the migration.
    func revert(on database: any Database) async throws {
        try await database.schema(Exercise.schema).delete()
    }
}

