import Foundation
import Fluent

protocol AuthRepository: Sendable {
    func createUser(email: String, passwordHash: String, on database: any Database) async throws -> User
    func findUser(byEmail email: String, on database: any Database) async throws -> User?
    func findUser(id: UUID, on database: any Database) async throws -> User?
    func createRefreshToken(id: UUID, userID: UUID, tokenHash: String, expiresAt: Date, on database: any Database) async throws -> RefreshToken
    func findRefreshToken(id: UUID, on database: any Database) async throws -> RefreshToken?
    func revokeRefreshToken(_ refreshToken: RefreshToken, on database: any Database) async throws
}

struct DefaultAuthRepository: AuthRepository {
    /// Creates a user record.
    ///
    /// - Parameters:
    ///   - email: The normalized email address.
    ///   - passwordHash: The hashed password.
    ///   - database: The database used for persistence.
    /// - Returns: The created user model.
    func createUser(email: String, passwordHash: String, on database: any Database) async throws -> User {
        let user = User(email: email, passwordHash: passwordHash)
        try await user.create(on: database)
        return user
    }

    /// Finds a user by normalized email.
    ///
    /// - Parameters:
    ///   - email: The normalized email address.
    ///   - database: The database used for lookup.
    /// - Returns: The matching user, if one exists.
    func findUser(byEmail email: String, on database: any Database) async throws -> User? {
        try await User.query(on: database)
            .filter(\.$email == email)
            .first()
    }

    /// Finds a user by identifier.
    ///
    /// - Parameters:
    ///   - id: The user identifier.
    ///   - database: The database used for lookup.
    /// - Returns: The matching user, if one exists.
    func findUser(id: UUID, on database: any Database) async throws -> User? {
        try await User.find(id, on: database)
    }

    /// Creates a refresh token record.
    ///
    /// - Parameters:
    ///   - id: The refresh token identifier.
    ///   - userID: The owner user identifier.
    ///   - tokenHash: The hashed refresh token secret.
    ///   - expiresAt: The token expiration date.
    ///   - database: The database used for persistence.
    /// - Returns: The created refresh token model.
    func createRefreshToken(
        id: UUID,
        userID: UUID,
        tokenHash: String,
        expiresAt: Date,
        on database: any Database
    ) async throws -> RefreshToken {
        let refreshToken = RefreshToken(id: id, userID: userID, tokenHash: tokenHash, expiresAt: expiresAt)
        try await refreshToken.create(on: database)
        return refreshToken
    }

    /// Finds a refresh token by identifier.
    ///
    /// - Parameters:
    ///   - id: The refresh token identifier.
    ///   - database: The database used for lookup.
    /// - Returns: The matching refresh token, if one exists.
    func findRefreshToken(id: UUID, on database: any Database) async throws -> RefreshToken? {
        try await RefreshToken.find(id, on: database)
    }

    /// Marks a refresh token as revoked.
    ///
    /// - Parameters:
    ///   - refreshToken: The refresh token to revoke.
    ///   - database: The database used for persistence.
    func revokeRefreshToken(_ refreshToken: RefreshToken, on database: any Database) async throws {
        refreshToken.revokedAt = Date()
        try await refreshToken.update(on: database)
    }
}
