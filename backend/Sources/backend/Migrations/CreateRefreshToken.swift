import Fluent

struct CreateRefreshToken: AsyncMigration {
    /// Creates the refresh tokens table.
    ///
    /// - Parameter database: The database that runs the migration.
    func prepare(on database: any Database) async throws {
        try await database.schema(RefreshToken.schema)
            .id()
            .field("user_id", .uuid, .required, .references(User.schema, .id, onDelete: .cascade))
            .field("token_hash", .string, .required)
            .field("expires_at", .datetime, .required)
            .field("revoked_at", .datetime)
            .field("created_at", .datetime, .required)
            .create()
    }

    /// Drops the refresh tokens table.
    ///
    /// - Parameter database: The database that reverts the migration.
    func revert(on database: any Database) async throws {
        try await database.schema(RefreshToken.schema).delete()
    }
}

