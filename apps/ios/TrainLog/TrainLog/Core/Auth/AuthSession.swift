import Foundation
import Observation

@MainActor
@Observable
final class AuthSession {
    private(set) var state: AuthSessionState = .restoring

    var isAuthenticated: Bool {
        switch state {
        case .signedIn:
            true
        case .restoring, .signedOut:
            false
        }
    }

    func restore(with storedSession: AuthStoredSession?) {
        guard let storedSession else {
            state = .signedOut
            return
        }

        state = .signedIn(user: storedSession.user)
    }

    func signIn(with session: AuthStoredSession) {
        state = .signedIn(user: session.user)
    }

    func signOut() {
        state = .signedOut
    }
}

enum AuthSessionState: Equatable, Sendable {
    case restoring
    case signedOut
    case signedIn(user: CurrentUser)
}

struct CurrentUser: Equatable, Identifiable, Sendable {
    let id: UUID
    let email: String
}
