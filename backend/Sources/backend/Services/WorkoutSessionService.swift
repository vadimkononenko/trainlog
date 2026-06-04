import Foundation
import Vapor

struct WorkoutSessionService: Sendable {
    private let repository: any WorkoutSessionRepository
    private let templateRepository: any WorkoutTemplateRepository
    private let exerciseRepository: any ExerciseRepository

    init(
        repository: any WorkoutSessionRepository,
        templateRepository: any WorkoutTemplateRepository,
        exerciseRepository: any ExerciseRepository
    ) {
        self.repository = repository
        self.templateRepository = templateRepository
        self.exerciseRepository = exerciseRepository
    }

    /// Lists sessions owned by the authenticated user.
    ///
    /// - Parameters:
    ///   - query: The list query DTO.
    ///   - user: The authenticated user.
    ///   - request: The HTTP request.
    /// - Returns: The paginated session response.
    func list(
        query: WorkoutSessionListQuery,
        for user: User,
        on request: Request
    ) async throws -> PaginatedResponseDTO<WorkoutSessionResponseDTO> {
        let page = normalizedPage(query.page)
        let limit = normalizedLimit(query.limit)
        let result = try await repository.list(for: try user.requireID(), page: page, limit: limit, on: request.db)

        return PaginatedResponseDTO(
            items: try result.sessions.map { try $0.toResponseDTO() },
            metadata: PaginationMetadataDTO(
                page: page,
                limit: limit,
                total: result.total,
                hasNextPage: page * limit < result.total
            )
        )
    }

    /// Creates a workout session for the authenticated user.
    ///
    /// - Parameters:
    ///   - dto: The create request DTO.
    ///   - id: Optional client-provided identifier used by sync push.
    ///   - user: The authenticated user.
    ///   - request: The HTTP request.
    /// - Returns: The created session response DTO.
    func create(
        _ dto: CreateWorkoutSessionRequest,
        id: UUID? = nil,
        for user: User,
        on request: Request
    ) async throws -> WorkoutSessionResponseDTO {
        let userID = try user.requireID()
        try await validateTemplateAccess(dto.templateId, userID: userID, on: request)
        try validateDateRange(startedAt: dto.startedAt, endedAt: dto.endedAt)
        let sessionID = id ?? UUID()
        let exercises = try await makeExerciseModels(from: dto.exercises, sessionID: sessionID, userID: userID, on: request)

        let session = WorkoutSession(
            id: sessionID,
            ownerUserID: userID,
            templateID: dto.templateId,
            startedAt: dto.startedAt,
            endedAt: dto.endedAt,
            notes: normalizeNotes(dto.notes)
        )

        _ = try await repository.create(session, on: request.db)
        try await repository.replaceExercises(exercises, sessionID: sessionID, on: request.db)

        guard let reloadedSession = try await repository.find(id: sessionID, for: userID, on: request.db) else {
            throw Abort(.internalServerError, reason: "Created session could not be loaded.")
        }
        return try reloadedSession.toResponseDTO()
    }

    /// Returns a session owned by the authenticated user.
    ///
    /// - Parameters:
    ///   - sessionID: The session identifier.
    ///   - user: The authenticated user.
    ///   - request: The HTTP request.
    /// - Returns: The session response DTO.
    func detail(sessionID: UUID, for user: User, on request: Request) async throws -> WorkoutSessionResponseDTO {
        guard let session = try await repository.find(id: sessionID, for: try user.requireID(), on: request.db) else {
            throw Abort(.notFound, reason: "Workout session not found.")
        }

        return try session.toResponseDTO()
    }

    /// Updates a workout session owned by the authenticated user.
    ///
    /// - Parameters:
    ///   - dto: The update request DTO.
    ///   - sessionID: The session identifier.
    ///   - user: The authenticated user.
    ///   - request: The HTTP request.
    /// - Returns: The updated session response DTO.
    func update(
        _ dto: UpdateWorkoutSessionRequest,
        sessionID: UUID,
        for user: User,
        on request: Request
    ) async throws -> WorkoutSessionResponseDTO {
        let userID = try user.requireID()
        guard let session = try await repository.find(id: sessionID, for: userID, on: request.db) else {
            throw Abort(.notFound, reason: "Workout session not found.")
        }

        var didChange = false
        if let templateID = dto.templateId {
            try await validateTemplateAccess(templateID, userID: userID, on: request)
            session.$template.id = templateID
            didChange = true
        }

        if let startedAt = dto.startedAt {
            session.startedAt = startedAt
            didChange = true
        }

        if let endedAt = dto.endedAt {
            session.endedAt = endedAt
            didChange = true
        }

        if let notes = dto.notes {
            session.notes = normalizeNotes(notes)
            didChange = true
        }

        try validateDateRange(startedAt: session.startedAt, endedAt: session.endedAt)

        if let exercises = dto.exercises {
            let exerciseModels = try await makeExerciseModels(from: exercises, sessionID: sessionID, userID: userID, on: request)
            try await repository.replaceExercises(exerciseModels, sessionID: sessionID, on: request.db)
            didChange = true
        }

        guard didChange else {
            throw Abort(.badRequest, reason: "At least one session field must be provided.")
        }

        session.version += 1
        _ = try await repository.update(session, on: request.db)

        guard let reloadedSession = try await repository.find(id: sessionID, for: userID, on: request.db) else {
            throw Abort(.internalServerError, reason: "Updated session could not be loaded.")
        }
        return try reloadedSession.toResponseDTO()
    }

    /// Replaces a session using a full sync payload.
    ///
    /// - Parameters:
    ///   - dto: The full session payload.
    ///   - sessionID: The session identifier.
    ///   - user: The authenticated user.
    ///   - request: The HTTP request.
    /// - Returns: The updated session response DTO.
    func replace(
        _ dto: CreateWorkoutSessionRequest,
        sessionID: UUID,
        for user: User,
        on request: Request
    ) async throws -> WorkoutSessionResponseDTO {
        try await update(
            UpdateWorkoutSessionRequest(
                templateId: .some(dto.templateId),
                startedAt: dto.startedAt,
                endedAt: .some(dto.endedAt),
                notes: .some(dto.notes),
                exercises: dto.exercises
            ),
            sessionID: sessionID,
            for: user,
            on: request
        )
    }

    /// Soft-deletes a workout session owned by the authenticated user.
    ///
    /// - Parameters:
    ///   - sessionID: The session identifier.
    ///   - user: The authenticated user.
    ///   - request: The HTTP request.
    func delete(sessionID: UUID, for user: User, on request: Request) async throws {
        guard let session = try await repository.find(id: sessionID, for: try user.requireID(), on: request.db) else {
            throw Abort(.notFound, reason: "Workout session not found.")
        }

        session.version += 1
        _ = try await repository.update(session, on: request.db)
        try await repository.delete(session, on: request.db)
    }

    /// Lists sessions changed since a timestamp for sync.
    ///
    /// - Parameters:
    ///   - since: The lower bound timestamp.
    ///   - user: The authenticated user.
    ///   - request: The HTTP request.
    /// - Returns: Changed session response DTOs.
    func listChanged(since: Date?, for user: User, on request: Request) async throws -> [WorkoutSessionResponseDTO] {
        try await repository
            .listChanged(for: try user.requireID(), since: since, on: request.db)
            .map { try $0.toResponseDTO() }
    }

    private func validateTemplateAccess(_ templateID: UUID?, userID: UUID, on request: Request) async throws {
        guard let templateID else {
            return
        }

        guard try await templateRepository.find(id: templateID, for: userID, on: request.db) != nil else {
            throw Abort(.badRequest, reason: "Workout template is not owned by the current user.")
        }
    }

    private func makeExerciseModels(
        from dtos: [WorkoutSessionExerciseRequest],
        sessionID: UUID,
        userID: UUID,
        on request: Request
    ) async throws -> [(WorkoutSessionExercise, [WorkoutSet])] {
        var exercises: [(WorkoutSessionExercise, [WorkoutSet])] = []

        for (exerciseIndex, dto) in dtos.enumerated() {
            guard try await exerciseRepository.findVisible(id: dto.exerciseId, for: userID, on: request.db) != nil else {
                throw Abort(.badRequest, reason: "Session exercise is not visible to the current user.")
            }

            let sessionExercise = WorkoutSessionExercise(
                sessionID: sessionID,
                exerciseID: dto.exerciseId,
                position: try validatePosition(dto.position ?? exerciseIndex + 1),
                notes: normalizeNotes(dto.notes)
            )

            let sets = try dto.sets.enumerated().map { setIndex, setDTO in
                WorkoutSet(
                    sessionExerciseID: UUID(),
                    position: try validatePosition(setDTO.position ?? setIndex + 1),
                    reps: try validateOptionalPositive(setDTO.reps, fieldName: "reps"),
                    weight: try validateOptionalNonNegative(setDTO.weight, fieldName: "weight"),
                    durationSeconds: try validateOptionalNonNegative(setDTO.durationSeconds, fieldName: "durationSeconds"),
                    distanceMeters: try validateOptionalNonNegative(setDTO.distanceMeters, fieldName: "distanceMeters"),
                    isCompleted: setDTO.isCompleted ?? true,
                    notes: normalizeNotes(setDTO.notes)
                )
            }

            exercises.append((sessionExercise, sets))
        }

        return exercises
    }

    private func validateDateRange(startedAt: Date, endedAt: Date?) throws {
        guard let endedAt else {
            return
        }

        guard endedAt >= startedAt else {
            throw Abort(.badRequest, reason: "endedAt must be greater than or equal to startedAt.")
        }
    }

    private func validatePosition(_ position: Int) throws -> Int {
        guard position > 0 else {
            throw Abort(.badRequest, reason: "Position must be greater than zero.")
        }
        return position
    }

    private func validateOptionalPositive(_ value: Int?, fieldName: String) throws -> Int? {
        guard let value else {
            return nil
        }
        guard value > 0 else {
            throw Abort(.badRequest, reason: "\(fieldName) must be greater than zero.")
        }
        return value
    }

    private func validateOptionalNonNegative(_ value: Int?, fieldName: String) throws -> Int? {
        guard let value else {
            return nil
        }
        guard value >= 0 else {
            throw Abort(.badRequest, reason: "\(fieldName) must be zero or greater.")
        }
        return value
    }

    private func validateOptionalNonNegative(_ value: Double?, fieldName: String) throws -> Double? {
        guard let value else {
            return nil
        }
        guard value >= 0 else {
            throw Abort(.badRequest, reason: "\(fieldName) must be zero or greater.")
        }
        return value
    }

    private func normalizeNotes(_ notes: String?) -> String? {
        let normalizedNotes = notes?.trimmingCharacters(in: .whitespacesAndNewlines)
        return normalizedNotes?.isEmpty == false ? normalizedNotes : nil
    }

    private func normalizedPage(_ page: Int?) -> Int {
        max(page ?? 1, 1)
    }

    private func normalizedLimit(_ limit: Int?) -> Int {
        min(max(limit ?? 20, 1), 100)
    }
}
