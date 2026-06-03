import SwiftUI

@MainActor
@Observable
final class ActiveWorkoutCoordinator {
    var path = NavigationPath()
    let viewModel = ActiveWorkoutViewModel()
}

struct ActiveWorkoutCoordinatorView: View {
    @Bindable private var coordinator: ActiveWorkoutCoordinator

    init(coordinator: ActiveWorkoutCoordinator) {
        self.coordinator = coordinator
    }

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            ActiveWorkoutView(viewModel: coordinator.viewModel)
        }
    }
}
