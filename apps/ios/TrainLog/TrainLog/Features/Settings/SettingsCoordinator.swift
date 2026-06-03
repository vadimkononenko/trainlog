import SwiftUI

@MainActor
@Observable
final class SettingsCoordinator {
    var path = NavigationPath()
    let viewModel: SettingsViewModel

    init(authSession: AuthSession) {
        self.viewModel = SettingsViewModel(authSession: authSession)
    }
}

struct SettingsCoordinatorView: View {
    @Bindable private var coordinator: SettingsCoordinator

    init(coordinator: SettingsCoordinator) {
        self.coordinator = coordinator
    }

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            SettingsView(viewModel: coordinator.viewModel)
        }
    }
}
