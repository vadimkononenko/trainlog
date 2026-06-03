import Observation

@MainActor
@Observable
final class SettingsViewModel {
    private let authSession: AuthSession

    init(authSession: AuthSession) {
        self.authSession = authSession
    }

    func signOut() {
        authSession.signOut()
    }
}
