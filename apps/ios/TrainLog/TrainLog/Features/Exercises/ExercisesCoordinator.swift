import SwiftUI

@MainActor
@Observable
final class ExercisesCoordinator {
    var path = NavigationPath()
    let viewModel = ExercisesViewModel()
}

struct ExercisesCoordinatorView: View {
    @Bindable private var coordinator: ExercisesCoordinator

    init(coordinator: ExercisesCoordinator) {
        self.coordinator = coordinator
    }

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            ExercisesView(viewModel: coordinator.viewModel)
        }
    }
}
