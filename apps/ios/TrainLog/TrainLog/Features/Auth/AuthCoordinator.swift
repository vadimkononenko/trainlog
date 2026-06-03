import SwiftUI

@MainActor
@Observable
final class AuthCoordinator {
    var path = NavigationPath()

    let viewModel: AuthViewModel

    init(authSession: AuthSession) {
        self.viewModel = AuthViewModel(authSession: authSession)
    }
}

struct AuthCoordinatorView: View {
    @Bindable private var coordinator: AuthCoordinator

    init(coordinator: AuthCoordinator) {
        self.coordinator = coordinator
    }

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            AuthView(viewModel: coordinator.viewModel)
        }
    }
}
