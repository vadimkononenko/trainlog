import Vapor

struct WorkoutTemplateController: RouteCollection {
    private let service: WorkoutTemplateService
    private let authenticator: AccessTokenAuthenticator

    init(service: WorkoutTemplateService, authenticator: AccessTokenAuthenticator) {
        self.service = service
        self.authenticator = authenticator
    }

    /// Registers workout template routes.
    ///
    /// - Parameter routes: The route builder used to register endpoints.
    func boot(routes: any RoutesBuilder) throws {
        let templates = routes
            .grouped(authenticator)
            .grouped(User.guardMiddleware())
            .grouped("workout-templates")

        templates.get(use: index)
        templates.post(use: create)
        templates.group(":templateID") { template in
            template.get(use: detail)
            template.patch(use: update)
            template.delete(use: delete)
        }
    }

    /// Lists workout templates owned by the current user.
    ///
    /// - Parameter request: The incoming HTTP request.
    /// - Returns: The paginated template response.
    @Sendable
    func index(request: Request) async throws -> PaginatedResponseDTO<WorkoutTemplateResponseDTO> {
        try await service.list(
            query: request.query.decode(WorkoutTemplateListQuery.self),
            for: request.auth.require(User.self),
            on: request
        )
    }

    /// Creates a workout template.
    ///
    /// - Parameter request: The incoming HTTP request.
    /// - Returns: The created template response DTO.
    @Sendable
    func create(request: Request) async throws -> WorkoutTemplateResponseDTO {
        try await service.create(
            request.content.decode(CreateWorkoutTemplateRequest.self),
            for: request.auth.require(User.self),
            on: request
        )
    }

    /// Returns workout template details.
    ///
    /// - Parameter request: The incoming HTTP request.
    /// - Returns: The template response DTO.
    @Sendable
    func detail(request: Request) async throws -> WorkoutTemplateResponseDTO {
        try await service.detail(
            templateID: try templateID(from: request),
            for: request.auth.require(User.self),
            on: request
        )
    }

    /// Updates a workout template.
    ///
    /// - Parameter request: The incoming HTTP request.
    /// - Returns: The updated template response DTO.
    @Sendable
    func update(request: Request) async throws -> WorkoutTemplateResponseDTO {
        try await service.update(
            request.content.decode(UpdateWorkoutTemplateRequest.self),
            templateID: try templateID(from: request),
            for: request.auth.require(User.self),
            on: request
        )
    }

    /// Deletes a workout template.
    ///
    /// - Parameter request: The incoming HTTP request.
    /// - Returns: A no-content status.
    @Sendable
    func delete(request: Request) async throws -> HTTPStatus {
        try await service.delete(
            templateID: try templateID(from: request),
            for: request.auth.require(User.self),
            on: request
        )
        return .noContent
    }

    private func templateID(from request: Request) throws -> UUID {
        guard let templateID = request.parameters.get("templateID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Template ID is invalid.")
        }
        return templateID
    }
}

