import Vapor

enum SyncMutationAction: String, Content, Sendable {
    case create
    case update
    case delete
}

struct SyncPullQuery: Content, Sendable {
    let since: Date?
}

struct SyncPullResponseDTO: Content, Sendable {
    let serverTime: Date
    let exercises: [ExerciseResponseDTO]
    let workoutTemplates: [WorkoutTemplateResponseDTO]
    let workoutSessions: [WorkoutSessionResponseDTO]
}

struct SyncPushRequest: Content, Sendable {
    let workoutTemplates: [SyncWorkoutTemplateMutation]
    let workoutSessions: [SyncWorkoutSessionMutation]
}

struct SyncWorkoutTemplateMutation: Content, Sendable {
    let action: SyncMutationAction
    let id: UUID?
    let template: CreateWorkoutTemplateRequest?
}

struct SyncWorkoutSessionMutation: Content, Sendable {
    let action: SyncMutationAction
    let id: UUID?
    let session: CreateWorkoutSessionRequest?
}

struct SyncPushResponseDTO: Content, Sendable {
    let serverTime: Date
    let workoutTemplates: [WorkoutTemplateResponseDTO]
    let workoutSessions: [WorkoutSessionResponseDTO]
    let deletedWorkoutTemplateIds: [UUID]
    let deletedWorkoutSessionIds: [UUID]
}

