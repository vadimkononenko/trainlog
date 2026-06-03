import Foundation
import Vapor

struct ExerciseService: Sendable {
    private let repository: any ExerciseRepository

    init(repository: any ExerciseRepository) {
        self.repository = repository
    }

    /// Lists exercises visible to the authenticated user.
    ///
    /// - Parameters:
    ///   - query: The list query DTO.
    ///   - user: The authenticated user.
    ///   - request: The HTTP request.
    /// - Returns: The paginated exercise response.
    func list(
        query: ExerciseListQuery,
        for user: User,
        on request: Request
    ) async throws -> PaginatedResponseDTO<ExerciseResponseDTO> {
        let page = normalizedPage(query.page)
        let limit = normalizedLimit(query.limit)
        let result = try await repository.listVisible(
            for: try user.requireID(),
            page: page,
            limit: limit,
            searchQuery: query.query,
            category: query.category,
            equipment: query.equipment,
            on: request.db
        )

        return PaginatedResponseDTO(
            items: try result.exercises.map { try $0.toResponseDTO() },
            metadata: PaginationMetadataDTO(
                page: page,
                limit: limit,
                total: result.total,
                hasNextPage: page * limit < result.total
            )
        )
    }

    /// Creates a custom exercise for the authenticated user.
    ///
    /// - Parameters:
    ///   - dto: The create request DTO.
    ///   - user: The authenticated user.
    ///   - request: The HTTP request.
    /// - Returns: The created exercise response DTO.
    func create(_ dto: CreateExerciseRequest, for user: User, on request: Request) async throws -> ExerciseResponseDTO {
        let exercise = Exercise(
            ownerUserID: try user.requireID(),
            name: try validateName(dto.name),
            category: dto.category,
            exerciseType: dto.exerciseType,
            equipment: dto.equipment,
            primaryMuscles: try validatePrimaryMuscles(dto.primaryMuscles),
            instructions: validateInstructions(dto.instructions)
        )

        return try await repository.create(exercise, on: request.db).toResponseDTO()
    }

    /// Returns an exercise visible to the authenticated user.
    ///
    /// - Parameters:
    ///   - exerciseID: The exercise identifier.
    ///   - user: The authenticated user.
    ///   - request: The HTTP request.
    /// - Returns: The exercise response DTO.
    func detail(exerciseID: UUID, for user: User, on request: Request) async throws -> ExerciseResponseDTO {
        guard let exercise = try await repository.findVisible(id: exerciseID, for: try user.requireID(), on: request.db) else {
            throw Abort(.notFound, reason: "Exercise not found.")
        }

        return try exercise.toResponseDTO()
    }

    /// Updates a custom exercise owned by the authenticated user.
    ///
    /// - Parameters:
    ///   - dto: The update request DTO.
    ///   - exerciseID: The exercise identifier.
    ///   - user: The authenticated user.
    ///   - request: The HTTP request.
    /// - Returns: The updated exercise response DTO.
    func update(
        _ dto: UpdateExerciseRequest,
        exerciseID: UUID,
        for user: User,
        on request: Request
    ) async throws -> ExerciseResponseDTO {
        guard let exercise = try await repository.findUserOwned(id: exerciseID, for: try user.requireID(), on: request.db) else {
            throw Abort(.notFound, reason: "Exercise not found.")
        }

        try apply(dto, to: exercise)
        exercise.version += 1

        return try await repository.update(exercise, on: request.db).toResponseDTO()
    }

    /// Deletes a custom exercise owned by the authenticated user.
    ///
    /// - Parameters:
    ///   - exerciseID: The exercise identifier.
    ///   - user: The authenticated user.
    ///   - request: The HTTP request.
    func delete(exerciseID: UUID, for user: User, on request: Request) async throws {
        guard let exercise = try await repository.findUserOwned(id: exerciseID, for: try user.requireID(), on: request.db) else {
            throw Abort(.notFound, reason: "Exercise not found.")
        }

        try await repository.delete(exercise, on: request.db)
    }

    /// Applies update DTO values to an exercise.
    ///
    /// - Parameters:
    ///   - dto: The update request DTO.
    ///   - exercise: The exercise model to mutate.
    private func apply(_ dto: UpdateExerciseRequest, to exercise: Exercise) throws {
        var didChange = false

        if let name = dto.name {
            exercise.name = try validateName(name)
            didChange = true
        }

        if let category = dto.category {
            exercise.category = category.rawValue
            didChange = true
        }

        if let exerciseType = dto.exerciseType {
            exercise.exerciseType = exerciseType.rawValue
            didChange = true
        }

        if let equipment = dto.equipment {
            exercise.equipment = equipment.rawValue
            didChange = true
        }

        if let primaryMuscles = dto.primaryMuscles {
            exercise.primaryMuscles = try validatePrimaryMuscles(primaryMuscles)
            didChange = true
        }

        if let instructions = dto.instructions {
            exercise.instructions = validateInstructions(instructions)
            didChange = true
        }

        guard didChange else {
            throw Abort(.badRequest, reason: "At least one exercise field must be provided.")
        }
    }

    /// Validates and normalizes an exercise name.
    ///
    /// - Parameter name: The raw exercise name.
    /// - Returns: The normalized exercise name.
    private func validateName(_ name: String) throws -> String {
        let normalizedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalizedName.isEmpty else {
            throw Abort(.badRequest, reason: "Exercise name is required.")
        }
        return normalizedName
    }

    /// Validates and normalizes primary muscles.
    ///
    /// - Parameter primaryMuscles: The raw primary muscle names.
    /// - Returns: The normalized primary muscle names.
    private func validatePrimaryMuscles(_ primaryMuscles: [String]) throws -> [String] {
        let normalizedMuscles = primaryMuscles
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        guard !normalizedMuscles.isEmpty else {
            throw Abort(.badRequest, reason: "At least one primary muscle is required.")
        }
        return normalizedMuscles
    }

    /// Normalizes exercise instructions.
    ///
    /// - Parameter instructions: The raw instructions.
    /// - Returns: The normalized instructions.
    private func validateInstructions(_ instructions: String) -> String {
        instructions.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Normalizes a page number.
    ///
    /// - Parameter page: The raw page number.
    /// - Returns: A positive page number.
    private func normalizedPage(_ page: Int?) -> Int {
        max(page ?? 1, 1)
    }

    /// Normalizes a page size.
    ///
    /// - Parameter limit: The raw page size.
    /// - Returns: A page size capped for API safety.
    private func normalizedLimit(_ limit: Int?) -> Int {
        min(max(limit ?? 20, 1), 100)
    }
}

