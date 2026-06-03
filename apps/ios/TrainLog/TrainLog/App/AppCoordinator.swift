import Observation

@MainActor
@Observable
final class AppCoordinator {
    let authCoordinator: AuthCoordinator
    let mainCoordinator: MainCoordinator

    private let authSession: AuthSession

    init(authSession: AuthSession) {
        self.authSession = authSession
        self.authCoordinator = AuthCoordinator(authSession: authSession)
        self.mainCoordinator = MainCoordinator(authSession: authSession)
    }

    var rootFlow: AppRootFlow {
        authSession.isAuthenticated ? .main : .auth
    }
}

enum AppRootFlow: Sendable {
    case auth
    case main
}
