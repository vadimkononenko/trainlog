import Observation

@MainActor
@Observable
final class WorkoutTemplatesViewModel {
    let emptyStateTitle = "No templates yet"
    let emptyStateMessage = "Saved workout plans will be built here in a later MVP step."
}
