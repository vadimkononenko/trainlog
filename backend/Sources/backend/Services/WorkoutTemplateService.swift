import Foundation
import Vapor

struct WorkoutTemplateService: Sendable {
    private let repository: any WorkoutTemplateRepository
    private let exerciseRepository: any ExerciseRepository

    init(repository: any WorkoutTemplateRepository, exerciseRepository: any ExerciseRepository) {
        self.repository = repository
        self.exerciseRepository = exerciseRepository
    }

    /// Lists templates owned by the authenticated user.
    ///
    /// - Parameters:
    ///   - query: The list query DTO.
    ///   - user: The authenticated user.
    ///   - request: The HTTP request.
    /// - Returns: The paginated template response.
    func list(
        query: WorkoutTemplateListQuery,
        for user: User,
        on request: Request
    ) async throws -> PaginatedResponseDTO<WorkoutTemplateResponseDTO> {
        let page = normalizedPage(query.page)
        let limit = normalizedLimit(query.limit)
        let result = try await repository.list(for: try user.requireID(), page: page, limit: limit, on: request.db)

        return PaginatedResponseDTO(
            items: try result.templates.map { try $0.toResponseDTO() },
            metadata: PaginationMetadataDTO(
                page: page,
                limit: limit,
                total: result.total,
                hasNextPage: page * limit < result.total
            )
        )
    }

    /// Creates a workout template for the authenticated user.
    ///
    /// - Parameters:
    ///   - dto: The create request DTO.
    ///   - id: Optional client-provided identifier used by sync push.
    ///   - user: The authenticated user.
    ///   - request: The HTTP request.
    /// - Returns: The created template response DTO.
    func create(
        _ dto: CreateWorkoutTemplateRequest,
        id: UUID? = nil,
        for user: User,
        on request: Request
    ) async throws -> WorkoutTemplateResponseDTO {
        let userID = try user.requireID()
        let templateID = id ?? UUID()
        let exercises = try await makeExerciseModels(from: dto.exercises, templateID: templateID, userID: userID, on: request)
        let template = WorkoutTemplate(
            id: templateID,
            ownerUserID: userID,
            name: try validateName(dto.name),
            notes: normalizeNotes(dto.notes)
        )

        _ = try await repository.create(template, on: request.db)
        try await repository.replaceExercises(exercises, templateID: templateID, on: request.db)

        guard let reloadedTemplate = try await repository.find(id: templateID, for: userID, on: request.db) else {
            throw Abort(.internalServerError, reason: "Created template could not be loaded.")
        }
        return try reloadedTemplate.toResponseDTO()
    }

    /// Returns a template owned by the authenticated user.
    ///
    /// - Parameters:
    ///   - templateID: The template identifier.
    ///   - user: The authenticated user.
    ///   - request: The HTTP request.
    /// - Returns: The template response DTO.
    func detail(templateID: UUID, for user: User, on request: Request) async throws -> WorkoutTemplateResponseDTO {
        guard let template = try await repository.find(id: templateID, for: try user.requireID(), on: request.db) else {
            throw Abort(.notFound, reason: "Workout template not found.")
        }

        return try template.toResponseDTO()
    }

    /// Updates a workout template owned by the authenticated user.
    ///
    /// - Parameters:
    ///   - dto: The update request DTO.
    ///   - templateID: The template identifier.
    ///   - user: The authenticated user.
    ///   - request: The HTTP request.
    /// - Returns: The updated template response DTO.
    func update(
        _ dto: UpdateWorkoutTemplateRequest,
        templateID: UUID,
        for user: User,
        on request: Request
    ) async throws -> WorkoutTemplateResponseDTO {
        let userID = try user.requireID()
        guard let template = try await repository.find(id: templateID, for: userID, on: request.db) else {
            throw Abort(.notFound, reason: "Workout template not found.")
        }

        var didChange = false
        if let name = dto.name {
            template.name = try validateName(name)
            didChange = true
        }

        if let notes = dto.notes {
            template.notes = normalizeNotes(notes)
            didChange = true
        }

        if let exercises = dto.exercises {
            let exerciseModels = try await makeExerciseModels(from: exercises, templateID: templateID, userID: userID, on: request)
            try await repository.replaceExercises(exerciseModels, templateID: templateID, on: request.db)
            didChange = true
        }

        guard didChange else {
            throw Abort(.badRequest, reason: "At least one template field must be provided.")
        }

        template.version += 1
        _ = try await repository.update(template, on: request.db)

        guard let reloadedTemplate = try await repository.find(id: templateID, for: userID, on: request.db) else {
            throw Abort(.internalServerError, reason: "Updated template could not be loaded.")
        }
        return try reloadedTemplate.toResponseDTO()
    }

    /// Replaces a template using a full sync payload.
    ///
    /// - Parameters:
    ///   - dto: The full template payload.
    ///   - templateID: The template identifier.
    ///   - user: The authenticated user.
    ///   - request: The HTTP request.
    /// - Returns: The updated template response DTO.
    func replace(
        _ dto: CreateWorkoutTemplateRequest,
        templateID: UUID,
        for user: User,
        on request: Request
    ) async throws -> WorkoutTemplateResponseDTO {
        try await update(
            UpdateWorkoutTemplateRequest(name: dto.name, notes: .some(dto.notes), exercises: dto.exercises),
            templateID: templateID,
            for: user,
            on: request
        )
    }

    /// Soft-deletes a workout template owned by the authenticated user.
    ///
    /// - Parameters:
    ///   - templateID: The template identifier.
    ///   - user: The authenticated user.
    ///   - request: The HTTP request.
    func delete(templateID: UUID, for user: User, on request: Request) async throws {
        guard let template = try await repository.find(id: templateID, for: try user.requireID(), on: request.db) else {
            throw Abort(.notFound, reason: "Workout template not found.")
        }

        template.version += 1
        _ = try await repository.update(template, on: request.db)
        try await repository.delete(template, on: request.db)
    }

    /// Lists templates changed since a timestamp for sync.
    ///
    /// - Parameters:
    ///   - since: The lower bound timestamp.
    ///   - user: The authenticated user.
    ///   - request: The HTTP request.
    /// - Returns: Changed template response DTOs.
    func listChanged(since: Date?, for user: User, on request: Request) async throws -> [WorkoutTemplateResponseDTO] {
        try await repository
            .listChanged(for: try user.requireID(), since: since, on: request.db)
            .map { try $0.toResponseDTO() }
    }

    private func makeExerciseModels(
        from dtos: [WorkoutTemplateExerciseRequest],
        templateID: UUID,
        userID: UUID,
        on request: Request
    ) async throws -> [WorkoutTemplateExercise] {
        var exercises: [WorkoutTemplateExercise] = []

        for (index, dto) in dtos.enumerated() {
            guard try await exerciseRepository.findVisible(id: dto.exerciseId, for: userID, on: request.db) != nil else {
                throw Abort(.badRequest, reason: "Template exercise is not visible to the current user.")
            }

            exercises.append(
                WorkoutTemplateExercise(
                    templateID: templateID,
                    exerciseID: dto.exerciseId,
                    position: try validatePosition(dto.position ?? index + 1),
                    targetSets: try validateOptionalPositive(dto.targetSets, fieldName: "targetSets"),
                    targetReps: try validateOptionalPositive(dto.targetReps, fieldName: "targetReps"),
                    targetWeight: try validateOptionalNonNegative(dto.targetWeight, fieldName: "targetWeight"),
                    restSeconds: try validateOptionalNonNegative(dto.restSeconds, fieldName: "restSeconds"),
                    notes: normalizeNotes(dto.notes)
                )
            )
        }

        return exercises
    }

    private func validateName(_ name: String) throws -> String {
        let normalizedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalizedName.isEmpty else {
            throw Abort(.badRequest, reason: "Template name is required.")
        }
        return normalizedName
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
