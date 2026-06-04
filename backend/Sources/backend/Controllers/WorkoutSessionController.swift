import Vapor

struct WorkoutSessionController: RouteCollection {
    private let service: WorkoutSessionService
    private let authenticator: AccessTokenAuthenticator

    init(service: WorkoutSessionService, authenticator: AccessTokenAuthenticator) {
        self.service = service
        self.authenticator = authenticator
    }

    /// Registers workout session routes.
    ///
    /// - Parameter routes: The route builder used to register endpoints.
    func boot(routes: any RoutesBuilder) throws {
        let sessions = routes
            .grouped(authenticator)
            .grouped(User.guardMiddleware())
            .grouped("workout-sessions")

        sessions.get(use: index)
        sessions.post(use: create)
        sessions.group(":sessionID") { session in
            session.get(use: detail)
            session.patch(use: update)
            session.delete(use: delete)
        }
    }

    /// Lists workout sessions owned by the current user.
    ///
    /// - Parameter request: The incoming HTTP request.
    /// - Returns: The paginated session response.
    @Sendable
    func index(request: Request) async throws -> PaginatedResponseDTO<WorkoutSessionResponseDTO> {
        try await service.list(
            query: request.query.decode(WorkoutSessionListQuery.self),
            for: request.auth.require(User.self),
            on: request
        )
    }

    /// Creates a workout session.
    ///
    /// - Parameter request: The incoming HTTP request.
    /// - Returns: The created session response DTO.
    @Sendable
    func create(request: Request) async throws -> WorkoutSessionResponseDTO {
        try await service.create(
            request.content.decode(CreateWorkoutSessionRequest.self),
            for: request.auth.require(User.self),
            on: request
        )
    }

    /// Returns workout session details.
    ///
    /// - Parameter request: The incoming HTTP request.
    /// - Returns: The session response DTO.
    @Sendable
    func detail(request: Request) async throws -> WorkoutSessionResponseDTO {
        try await service.detail(
            sessionID: try sessionID(from: request),
            for: request.auth.require(User.self),
            on: request
        )
    }

    /// Updates a workout session.
    ///
    /// - Parameter request: The incoming HTTP request.
    /// - Returns: The updated session response DTO.
    @Sendable
    func update(request: Request) async throws -> WorkoutSessionResponseDTO {
        try await service.update(
            request.content.decode(UpdateWorkoutSessionRequest.self),
            sessionID: try sessionID(from: request),
            for: request.auth.require(User.self),
            on: request
        )
    }

    /// Deletes a workout session.
    ///
    /// - Parameter request: The incoming HTTP request.
    /// - Returns: A no-content status.
    @Sendable
    func delete(request: Request) async throws -> HTTPStatus {
        try await service.delete(
            sessionID: try sessionID(from: request),
            for: request.auth.require(User.self),
            on: request
        )
        return .noContent
    }

    private func sessionID(from request: Request) throws -> UUID {
        guard let sessionID = request.parameters.get("sessionID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Session ID is invalid.")
        }
        return sessionID
    }
}

