import Vapor

struct RefreshTokenPlainValue: Sendable {
    let id: UUID
    let secret: String
    let rawValue: String
}

struct AuthTokenService: Sendable {
    private let accessTokenLifetime: TimeInterval
    private let refreshTokenLifetime: TimeInterval

    init(accessTokenLifetime: TimeInterval = 900, refreshTokenLifetime: TimeInterval = 2_592_000) {
        self.accessTokenLifetime = accessTokenLifetime
        self.refreshTokenLifetime = refreshTokenLifetime
    }

    /// Creates a signed JWT access token for a user.
    ///
    /// - Parameters:
    ///   - user: The authenticated user.
    ///   - request: The request used to access JWT signing services.
    /// - Returns: The signed access token.
    func makeAccessToken(for user: User, on request: Request) async throws -> String {
        let payload = AccessTokenPayload(
            userID: try user.requireID(),
            expiresAt: Date().addingTimeInterval(accessTokenLifetime)
        )
        return try await request.jwt.sign(payload)
    }

    /// Creates a new plaintext refresh token value.
    ///
    /// - Returns: The refresh token identifier, secret, and raw client value.
    func makeRefreshTokenValue() -> RefreshTokenPlainValue {
        let id = UUID()
        let secret = [UInt8].random(count: 32).base64String()
        return RefreshTokenPlainValue(
            id: id,
            secret: secret,
            rawValue: "\(id.uuidString).\(secret)"
        )
    }

    /// Hashes a refresh token secret for storage.
    ///
    /// - Parameter secret: The plaintext refresh token secret.
    /// - Returns: The hashed refresh token secret.
    func hashRefreshTokenSecret(_ secret: String) throws -> String {
        try Bcrypt.hash(secret)
    }

    /// Verifies a plaintext refresh token secret against a stored hash.
    ///
    /// - Parameters:
    ///   - secret: The plaintext refresh token secret.
    ///   - hash: The stored refresh token hash.
    /// - Returns: `true` when the secret matches the stored hash.
    func verifyRefreshTokenSecret(_ secret: String, hash: String) throws -> Bool {
        try Bcrypt.verify(secret, created: hash)
    }

    /// Calculates the expiration date for a new refresh token.
    ///
    /// - Returns: The refresh token expiration date.
    func makeRefreshTokenExpirationDate() -> Date {
        Date().addingTimeInterval(refreshTokenLifetime)
    }

    /// Parses the raw refresh token value sent by the client.
    ///
    /// - Parameter rawValue: The raw refresh token value.
    /// - Returns: The refresh token identifier and plaintext secret.
    func parseRefreshToken(_ rawValue: String) throws -> RefreshTokenPlainValue {
        let parts = rawValue.split(separator: ".", maxSplits: 1).map(String.init)
        guard parts.count == 2, let id = UUID(uuidString: parts[0]), !parts[1].isEmpty else {
            throw Abort(.unauthorized, reason: "Invalid refresh token.")
        }
        return RefreshTokenPlainValue(id: id, secret: parts[1], rawValue: rawValue)
    }
}

