import Observation

@MainActor
@Observable
final class ActiveWorkoutViewModel {
    let emptyStateTitle = "Ready when you are"
    let emptyStateMessage = "Active workout logging will start as a local-only flow."
}
