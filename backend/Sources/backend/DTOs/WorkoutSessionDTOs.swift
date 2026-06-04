import Vapor

struct WorkoutSessionListQuery: Content, Sendable {
    let page: Int?
    let limit: Int?
}

struct CreateWorkoutSessionRequest: Content, Sendable {
    let templateId: UUID?
    let startedAt: Date
    let endedAt: Date?
    let notes: String?
    let exercises: [WorkoutSessionExerciseRequest]
}

struct UpdateWorkoutSessionRequest: Content, Sendable {
    let templateId: UUID??
    let startedAt: Date?
    let endedAt: Date??
    let notes: String??
    let exercises: [WorkoutSessionExerciseRequest]?
}

struct WorkoutSessionExerciseRequest: Content, Sendable {
    let exerciseId: UUID
    let position: Int?
    let notes: String?
    let sets: [WorkoutSetRequest]
}

struct WorkoutSetRequest: Content, Sendable {
    let position: Int?
    let reps: Int?
    let weight: Double?
    let durationSeconds: Int?
    let distanceMeters: Double?
    let isCompleted: Bool?
    let notes: String?
}

struct WorkoutSessionResponseDTO: Content, Sendable {
    let id: UUID
    let ownerUserId: UUID
    let templateId: UUID?
    let startedAt: Date
    let endedAt: Date?
    let notes: String?
    let exercises: [WorkoutSessionExerciseResponseDTO]
    let createdAt: Date?
    let updatedAt: Date?
    let deletedAt: Date?
    let version: Int
}

struct WorkoutSessionExerciseResponseDTO: Content, Sendable {
    let id: UUID
    let exerciseId: UUID
    let position: Int
    let notes: String?
    let sets: [WorkoutSetResponseDTO]
}

struct WorkoutSetResponseDTO: Content, Sendable {
    let id: UUID
    let position: Int
    let reps: Int?
    let weight: Double?
    let durationSeconds: Int?
    let distanceMeters: Double?
    let isCompleted: Bool
    let notes: String?
}
