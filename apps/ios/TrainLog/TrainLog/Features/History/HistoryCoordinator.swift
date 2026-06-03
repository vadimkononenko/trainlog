import SwiftUI

@MainActor
@Observable
final class HistoryCoordinator {
    var path = NavigationPath()
    let viewModel = HistoryViewModel()
}

struct HistoryCoordinatorView: View {
    @Bindable private var coordinator: HistoryCoordinator

    init(coordinator: HistoryCoordinator) {
        self.coordinator = coordinator
    }

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            HistoryView(viewModel: coordinator.viewModel)
        }
    }
}
