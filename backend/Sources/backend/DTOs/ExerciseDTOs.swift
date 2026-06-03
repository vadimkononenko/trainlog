import Vapor

enum ExerciseCategory: String, Content, Sendable, CaseIterable {
    case chest
    case back
    case legs
    case shoulders
    case arms
    case core
    case cardio
    case other
}

enum ExerciseType: String, Content, Sendable, CaseIterable {
    case strength
    case cardio
    case mobility
    case bodyweight
}

enum ExerciseEquipment: String, Content, Sendable, CaseIterable {
    case barbell
    case dumbbell
    case machine
    case band
    case bodyweight
    case cable
    case kettlebell
    case other
}

struct ExerciseListQuery: Content, Sendable {
    let page: Int?
    let limit: Int?
    let query: String?
    let category: ExerciseCategory?
    let equipment: ExerciseEquipment?
}

struct CreateExerciseRequest: Content, Sendable {
    let name: String
    let category: ExerciseCategory
    let exerciseType: ExerciseType
    let equipment: ExerciseEquipment
    let primaryMuscles: [String]
    let instructions: String
}

struct UpdateExerciseRequest: Content, Sendable {
    let name: String?
    let category: ExerciseCategory?
    let exerciseType: ExerciseType?
    let equipment: ExerciseEquipment?
    let primaryMuscles: [String]?
    let instructions: String?
}

struct ExerciseResponseDTO: Content, Sendable {
    let id: UUID
    let ownerUserId: UUID?
    let name: String
    let category: ExerciseCategory
    let exerciseType: ExerciseType
    let equipment: ExerciseEquipment
    let primaryMuscles: [String]
    let instructions: String
    let createdAt: Date?
    let updatedAt: Date?
    let deletedAt: Date?
    let version: Int
}

