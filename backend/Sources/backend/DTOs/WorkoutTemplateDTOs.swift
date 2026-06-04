import Vapor

struct WorkoutTemplateListQuery: Content, Sendable {
    let page: Int?
    let limit: Int?
}

struct CreateWorkoutTemplateRequest: Content, Sendable {
    let name: String
    let notes: String?
    let exercises: [WorkoutTemplateExerciseRequest]
}

struct UpdateWorkoutTemplateRequest: Content, Sendable {
    let name: String?
    let notes: String??
    let exercises: [WorkoutTemplateExerciseRequest]?
}

struct WorkoutTemplateExerciseRequest: Content, Sendable {
    let exerciseId: UUID
    let position: Int?
    let targetSets: Int?
    let targetReps: Int?
    let targetWeight: Double?
    let restSeconds: Int?
    let notes: String?
}

struct WorkoutTemplateResponseDTO: Content, Sendable {
    let id: UUID
    let ownerUserId: UUID
    let name: String
    let notes: String?
    let exercises: [WorkoutTemplateExerciseResponseDTO]
    let createdAt: Date?
    let updatedAt: Date?
    let deletedAt: Date?
    let version: Int
}

struct WorkoutTemplateExerciseResponseDTO: Content, Sendable {
    let id: UUID
    let exerciseId: UUID
    let position: Int
    let targetSets: Int?
    let targetReps: Int?
    let targetWeight: Double?
    let restSeconds: Int?
    let notes: String?
}
