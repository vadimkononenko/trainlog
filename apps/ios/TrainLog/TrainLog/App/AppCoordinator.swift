import Observation

@MainActor
@Observable
final class AppCoordinator {
    let authCoordinator: AuthCoordinator
    let mainCoordinator: MainCoordinator

    private let authSession: AuthSession
    private let authRepository: AuthRepository
    private var didRestoreSession = false

    init(
        authSession: AuthSession,
        authRepository: AuthRepository
    ) {
        self.authSession = authSession
        self.authRepository = authRepository
        self.authCoordinator = AuthCoordinator(
            authSession: authSession,
            authRepository: authRepository
        )
        self.mainCoordinator = MainCoordinator(
            authSession: authSession,
            authRepository: authRepository
        )
    }

    var rootFlow: AppRootFlow {
        switch authSession.state {
        case .restoring:
            .restoring
        case .signedOut:
            .auth
        case .signedIn:
            .main
        }
    }

    func restoreSessionIfNeeded() async {
        guard !didRestoreSession else {
            return
        }

        didRestoreSession = true

        do {
            let storedSession = try await authRepository.restoreSession()
            authSession.restore(with: storedSession)
        } catch {
            authSession.restore(with: nil)
        }
    }
}

enum AppRootFlow: Sendable {
    case restoring
    case auth
    case main
}
