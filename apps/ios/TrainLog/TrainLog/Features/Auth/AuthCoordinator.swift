import SwiftUI

@MainActor
@Observable
final class AuthCoordinator {
    var path = NavigationPath()

    let signInViewModel: SignInViewModel
    let signUpViewModel: SignUpViewModel

    init(
        authSession: AuthSession,
        authRepository: AuthRepository
    ) {
        self.signInViewModel = SignInViewModel(
            authSession: authSession,
            authRepository: authRepository
        )
        self.signUpViewModel = SignUpViewModel(
            authSession: authSession,
            authRepository: authRepository
        )
    }

    func showSignUp() {
        path.append(AuthRoute.signUp)
    }

    func showSignIn() {
        path.removeLast(path.count)
    }
}

enum AuthRoute: Hashable {
    case signUp
}

struct AuthCoordinatorView: View {
    @Bindable private var coordinator: AuthCoordinator

    init(coordinator: AuthCoordinator) {
        self.coordinator = coordinator
    }

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            SignInView(
                viewModel: coordinator.signInViewModel,
                onSignUp: {
                    coordinator.showSignUp()
                }
            )
            .navigationDestination(for: AuthRoute.self) { route in
                switch route {
                case .signUp:
                    SignUpView(
                        viewModel: coordinator.signUpViewModel,
                        onSignIn: {
                            coordinator.showSignIn()
                        }
                    )
                }
            }
        }
    }
}
