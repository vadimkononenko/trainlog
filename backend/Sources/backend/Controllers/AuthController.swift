import Vapor

struct AuthController: RouteCollection {
    private let service: AuthService
    private let authenticator: AccessTokenAuthenticator

    init(service: AuthService, authenticator: AccessTokenAuthenticator) {
        self.service = service
        self.authenticator = authenticator
    }

    /// Registers auth routes.
    ///
    /// - Parameter routes: The route builder used to register endpoints.
    func boot(routes: any RoutesBuilder) throws {
        let auth = routes.grouped("auth")

        auth.post("register", use: register)
        auth.post("login", use: login)
        auth.post("refresh", use: refresh)
        auth.post("logout", use: logout)

        let protected = routes
            .grouped(authenticator)
            .grouped(User.guardMiddleware())
        protected.get("me", use: currentUser)
    }

    /// Registers a new user.
    ///
    /// - Parameter request: The incoming HTTP request.
    /// - Returns: The auth response DTO.
    @Sendable
    func register(request: Request) async throws -> AuthResponseDTO {
        try await service.register(request.content.decode(RegisterRequest.self), on: request)
    }

    /// Logs in an existing user.
    ///
    /// - Parameter request: The incoming HTTP request.
    /// - Returns: The auth response DTO.
    @Sendable
    func login(request: Request) async throws -> AuthResponseDTO {
        try await service.login(request.content.decode(LoginRequest.self), on: request)
    }

    /// Refreshes an auth session.
    ///
    /// - Parameter request: The incoming HTTP request.
    /// - Returns: The auth response DTO.
    @Sendable
    func refresh(request: Request) async throws -> AuthResponseDTO {
        try await service.refresh(request.content.decode(RefreshTokenRequest.self), on: request)
    }

    /// Logs out an auth session.
    ///
    /// - Parameter request: The incoming HTTP request.
    /// - Returns: A no-content status.
    @Sendable
    func logout(request: Request) async throws -> HTTPStatus {
        try await service.logout(request.content.decode(LogoutRequest.self), on: request)
        return .noContent
    }

    /// Returns the current authenticated user.
    ///
    /// - Parameter request: The incoming HTTP request.
    /// - Returns: The current user response DTO.
    @Sendable
    func currentUser(request: Request) async throws -> UserResponseDTO {
        try service.makeCurrentUserResponse(for: request.auth.require(User.self))
    }
}

