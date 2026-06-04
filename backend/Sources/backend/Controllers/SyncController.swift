import Vapor

struct SyncController: RouteCollection {
    private let service: SyncService
    private let authenticator: AccessTokenAuthenticator

    init(service: SyncService, authenticator: AccessTokenAuthenticator) {
        self.service = service
        self.authenticator = authenticator
    }

    /// Registers sync routes.
    ///
    /// - Parameter routes: The route builder used to register endpoints.
    func boot(routes: any RoutesBuilder) throws {
        let sync = routes
            .grouped(authenticator)
            .grouped(User.guardMiddleware())
            .grouped("sync")

        sync.get("pull", use: pull)
        sync.post("push", use: push)
    }

    /// Pulls server changes visible to the current user.
    ///
    /// - Parameter request: The incoming HTTP request.
    /// - Returns: The sync pull response DTO.
    @Sendable
    func pull(request: Request) async throws -> SyncPullResponseDTO {
        try await service.pull(
            query: request.query.decode(SyncPullQuery.self),
            for: request.auth.require(User.self),
            on: request
        )
    }

    /// Applies client sync mutations.
    ///
    /// - Parameter request: The incoming HTTP request.
    /// - Returns: The accepted sync mutations.
    @Sendable
    func push(request: Request) async throws -> SyncPushResponseDTO {
        try await service.push(
            request.content.decode(SyncPushRequest.self),
            for: request.auth.require(User.self),
            on: request
        )
    }
}

