import SwiftUI

@MainActor
@Observable
final class WorkoutTemplatesCoordinator {
    var path = NavigationPath()
    let viewModel = WorkoutTemplatesViewModel()
}

struct WorkoutTemplatesCoordinatorView: View {
    @Bindable private var coordinator: WorkoutTemplatesCoordinator

    init(coordinator: WorkoutTemplatesCoordinator) {
        self.coordinator = coordinator
    }

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            WorkoutTemplatesView(viewModel: coordinator.viewModel)
        }
    }
}
