import Observation

@MainActor
@Observable
final class HistoryViewModel {
    let emptyStateTitle = "No workouts recorded"
    let emptyStateMessage = "Completed workout sessions will be listed here."
}
