import SwiftUI

struct MainCoordinatorView: View {
    @Bindable private var coordinator: MainCoordinator

    init(coordinator: MainCoordinator) {
        self.coordinator = coordinator
    }

    var body: some View {
        TabView(selection: $coordinator.selectedTab) {
            ExercisesCoordinatorView(coordinator: coordinator.exercisesCoordinator)
                .tabItem {
                    Label("Exercises", systemImage: "figure.strengthtraining.traditional")
                }
                .tag(MainTab.exercises)

            WorkoutTemplatesCoordinatorView(coordinator: coordinator.workoutTemplatesCoordinator)
                .tabItem {
                    Label("Templates", systemImage: "list.clipboard")
                }
                .tag(MainTab.templates)

            ActiveWorkoutCoordinatorView(coordinator: coordinator.activeWorkoutCoordinator)
                .tabItem {
                    Label("Workout", systemImage: "play.circle.fill")
                }
                .tag(MainTab.activeWorkout)

            HistoryCoordinatorView(coordinator: coordinator.historyCoordinator)
                .tabItem {
                    Label("History", systemImage: "clock.arrow.circlepath")
                }
                .tag(MainTab.history)

            SettingsCoordinatorView(coordinator: coordinator.settingsCoordinator)
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
                .tag(MainTab.settings)
        }
    }
}
