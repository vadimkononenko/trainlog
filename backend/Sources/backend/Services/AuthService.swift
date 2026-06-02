import Vapor

struct AuthService: Sendable {
    private let repository: any AuthRepository
    private let tokenService: AuthTokenService

    init(repository: any AuthRepository, tokenService: AuthTokenService = AuthTokenService()) {
        self.repository = repository
        self.tokenService = tokenService
    }

    /// Registers a new user and issues auth tokens.
    ///
    /// - Parameters:
    ///   - dto: The register request DTO.
    ///   - request: The HTTP request.
    /// - Returns: The issued auth response.
    func register(_ dto: RegisterRequest, on request: Request) async throws -> AuthResponseDTO {
        let email = try normalizeAndValidateEmail(dto.email)
        try validatePassword(dto.password)

        guard try await repository.findUser(byEmail: email, on: request.db) == nil else {
            throw Abort(.conflict, reason: "Email is already registered.")
        }

        let passwordHash = try Bcrypt.hash(dto.password)
        let user = try await repository.createUser(email: email, passwordHash: passwordHash, on: request.db)
        return try await issueTokens(for: user, on: request)
    }

    /// Logs in an existing user and issues auth tokens.
    ///
    /// - Parameters:
    ///   - dto: The login request DTO.
    ///   - request: The HTTP request.
    /// - Returns: The issued auth response.
    func login(_ dto: LoginRequest, on request: Request) async throws -> AuthResponseDTO {
        let email = try normalizeAndValidateEmail(dto.email)

        guard
            let user = try await repository.findUser(byEmail: email, on: request.db),
            try Bcrypt.verify(dto.password, created: user.passwordHash)
        else {
            throw Abort(.unauthorized, reason: "Invalid email or password.")
        }

        return try await issueTokens(for: user, on: request)
    }

    /// Rotates a valid refresh token and issues a new access token.
    ///
    /// - Parameters:
    ///   - dto: The refresh token request DTO.
    ///   - request: The HTTP request.
    /// - Returns: The issued auth response.
    func refresh(_ dto: RefreshTokenRequest, on request: Request) async throws -> AuthResponseDTO {
        let refreshTokenValue = try tokenService.parseRefreshToken(dto.refreshToken)
        let refreshToken = try await requireActiveRefreshToken(refreshTokenValue, on: request)
        let user = try await refreshToken.$user.get(on: request.db)

        try await repository.revokeRefreshToken(refreshToken, on: request.db)
        return try await issueTokens(for: user, on: request)
    }

    /// Revokes a refresh token.
    ///
    /// - Parameters:
    ///   - dto: The logout request DTO.
    ///   - request: The HTTP request.
    func logout(_ dto: LogoutRequest, on request: Request) async throws {
        let refreshTokenValue = try tokenService.parseRefreshToken(dto.refreshToken)
        let refreshToken = try await requireActiveRefreshToken(refreshTokenValue, on: request)
        try await repository.revokeRefreshToken(refreshToken, on: request.db)
    }

    /// Loads the current authenticated user response.
    ///
    /// - Parameter user: The authenticated user model.
    /// - Returns: The public user response DTO.
    func makeCurrentUserResponse(for user: User) throws -> UserResponseDTO {
        try user.toResponseDTO()
    }

    /// Issues a new access token and refresh token pair.
    ///
    /// - Parameters:
    ///   - user: The authenticated user.
    ///   - request: The HTTP request.
    /// - Returns: The auth response DTO.
    private func issueTokens(for user: User, on request: Request) async throws -> AuthResponseDTO {
        let refreshTokenValue = tokenService.makeRefreshTokenValue()
        let refreshTokenHash = try tokenService.hashRefreshTokenSecret(refreshTokenValue.secret)
        _ = try await repository.createRefreshToken(
            id: refreshTokenValue.id,
            userID: try user.requireID(),
            tokenHash: refreshTokenHash,
            expiresAt: tokenService.makeRefreshTokenExpirationDate(),
            on: request.db
        )

        return AuthResponseDTO(
            accessToken: try await tokenService.makeAccessToken(for: user, on: request),
            refreshToken: refreshTokenValue.rawValue,
            user: try user.toResponseDTO()
        )
    }

    /// Loads and validates a refresh token.
    ///
    /// - Parameters:
    ///   - value: The parsed refresh token value.
    ///   - request: The HTTP request.
    /// - Returns: The active refresh token model.
    private func requireActiveRefreshToken(_ value: RefreshTokenPlainValue, on request: Request) async throws -> RefreshToken {
        guard
            let refreshToken = try await repository.findRefreshToken(id: value.id, on: request.db),
            refreshToken.isActive(),
            try tokenService.verifyRefreshTokenSecret(value.secret, hash: refreshToken.tokenHash)
        else {
            throw Abort(.unauthorized, reason: "Invalid refresh token.")
        }
        return refreshToken
    }

    /// Normalizes and validates an email address.
    ///
    /// - Parameter email: The raw email address.
    /// - Returns: The normalized email address.
    private func normalizeAndValidateEmail(_ email: String) throws -> String {
        let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard normalizedEmail.contains("@"), normalizedEmail.contains(".") else {
            throw Abort(.badRequest, reason: "Email is invalid.")
        }
        return normalizedEmail
    }

    /// Validates a plaintext password.
    ///
    /// - Parameter password: The plaintext password.
    private func validatePassword(_ password: String) throws {
        guard password.count >= 8 else {
            throw Abort(.badRequest, reason: "Password must be at least 8 characters.")
        }
    }
}
