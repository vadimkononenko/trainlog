import Observation

@MainActor
@Observable
final class ExercisesViewModel {
    let emptyStateTitle = "No exercises loaded"
    let emptyStateMessage = "The exercise catalog will appear here after networking and SwiftData are connected."
}
