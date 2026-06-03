import Observation

@MainActor
@Observable
final class AuthViewModel {
    private let authSession: AuthSession

    var email = ""
    var password = ""

    init(authSession: AuthSession) {
        self.authSession = authSession
    }

    func continueWithPlaceholderSession() {
        authSession.completePlaceholderSignIn()
    }
}
