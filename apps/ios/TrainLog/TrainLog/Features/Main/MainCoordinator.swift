import Observation

@MainActor
@Observable
final class MainCoordinator {
    var selectedTab: MainTab = .exercises

    let exercisesCoordinator = ExercisesCoordinator()
    let workoutTemplatesCoordinator = WorkoutTemplatesCoordinator()
    let activeWorkoutCoordinator = ActiveWorkoutCoordinator()
    let historyCoordinator = HistoryCoordinator()
    let settingsCoordinator: SettingsCoordinator

    init(authSession: AuthSession) {
        self.settingsCoordinator = SettingsCoordinator(authSession: authSession)
    }
}

enum MainTab: Hashable, Sendable {
    case exercises
    case templates
    case activeWorkout
    case history
    case settings
}
