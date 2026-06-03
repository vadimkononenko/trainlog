import Vapor

struct ExerciseController: RouteCollection {
    private let service: ExerciseService
    private let authenticator: AccessTokenAuthenticator

    init(service: ExerciseService, authenticator: AccessTokenAuthenticator) {
        self.service = service
        self.authenticator = authenticator
    }

    /// Registers exercise routes.
    ///
    /// - Parameter routes: The route builder used to register endpoints.
    func boot(routes: any RoutesBuilder) throws {
        let exercises = routes
            .grouped(authenticator)
            .grouped(User.guardMiddleware())
            .grouped("exercises")

        exercises.get(use: index)
        exercises.post(use: create)
        exercises.group(":exerciseID") { exercise in
            exercise.get(use: detail)
            exercise.patch(use: update)
            exercise.delete(use: delete)
        }
    }

    /// Lists exercises visible to the current user.
    ///
    /// - Parameter request: The incoming HTTP request.
    /// - Returns: The paginated exercise response.
    @Sendable
    func index(request: Request) async throws -> PaginatedResponseDTO<ExerciseResponseDTO> {
        try await service.list(
            query: request.query.decode(ExerciseListQuery.self),
            for: request.auth.require(User.self),
            on: request
        )
    }

    /// Creates a custom exercise.
    ///
    /// - Parameter request: The incoming HTTP request.
    /// - Returns: The created exercise response DTO.
    @Sendable
    func create(request: Request) async throws -> ExerciseResponseDTO {
        try await service.create(
            request.content.decode(CreateExerciseRequest.self),
            for: request.auth.require(User.self),
            on: request
        )
    }

    /// Returns exercise details.
    ///
    /// - Parameter request: The incoming HTTP request.
    /// - Returns: The exercise response DTO.
    @Sendable
    func detail(request: Request) async throws -> ExerciseResponseDTO {
        try await service.detail(
            exerciseID: try exerciseID(from: request),
            for: request.auth.require(User.self),
            on: request
        )
    }

    /// Updates a custom exercise.
    ///
    /// - Parameter request: The incoming HTTP request.
    /// - Returns: The updated exercise response DTO.
    @Sendable
    func update(request: Request) async throws -> ExerciseResponseDTO {
        try await service.update(
            request.content.decode(UpdateExerciseRequest.self),
            exerciseID: try exerciseID(from: request),
            for: request.auth.require(User.self),
            on: request
        )
    }

    /// Deletes a custom exercise.
    ///
    /// - Parameter request: The incoming HTTP request.
    /// - Returns: A no-content status.
    @Sendable
    func delete(request: Request) async throws -> HTTPStatus {
        try await service.delete(
            exerciseID: try exerciseID(from: request),
            for: request.auth.require(User.self),
            on: request
        )
        return .noContent
    }

    /// Extracts the exercise identifier from route parameters.
    ///
    /// - Parameter request: The incoming HTTP request.
    /// - Returns: The exercise identifier.
    private func exerciseID(from request: Request) throws -> UUID {
        guard let exerciseID = request.parameters.get("exerciseID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Exercise ID is invalid.")
        }
        return exerciseID
    }
}

