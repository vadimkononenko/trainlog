import SwiftUI

@MainActor
@Observable
final class SettingsCoordinator {
    var path = NavigationPath()
    let viewModel: SettingsViewModel

    init(
        authSession: AuthSession,
        authRepository: AuthRepository
    ) {
        self.viewModel = SettingsViewModel(
            authSession: authSession,
            authRepository: authRepository
        )
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
