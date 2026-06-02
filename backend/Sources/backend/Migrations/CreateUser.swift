import Fluent

struct CreateUser: AsyncMigration {
    /// Creates the users table.
    ///
    /// - Parameter database: The database that runs the migration.
    func prepare(on database: any Database) async throws {
        try await database.schema(User.schema)
            .id()
            .field("email", .string, .required)
            .field("password_hash", .string, .required)
            .field("created_at", .datetime, .required)
            .field("updated_at", .datetime, .required)
            .unique(on: "email")
            .create()
    }

    /// Drops the users table.
    ///
    /// - Parameter database: The database that reverts the migration.
    func revert(on database: any Database) async throws {
        try await database.schema(User.schema).delete()
    }
}

