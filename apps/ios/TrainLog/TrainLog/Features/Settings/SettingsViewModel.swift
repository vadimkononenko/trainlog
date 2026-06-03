import Observation

@MainActor
@Observable
final class SettingsViewModel {
    private let authSession: AuthSession
    private let authRepository: AuthRepository

    var isSigningOut = false

    init(
        authSession: AuthSession,
        authRepository: AuthRepository
    ) {
        self.authSession = authSession
        self.authRepository = authRepository
    }

    func signOut() async {
        isSigningOut = true
        defer { isSigningOut = false }

        try? await authRepository.signOut()
        authSession.signOut()
    }
}
