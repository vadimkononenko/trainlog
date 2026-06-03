import Foundation
import Observation

@MainActor
@Observable
final class AuthSession {
    private(set) var state: AuthSessionState = .signedOut

    var isAuthenticated: Bool {
        switch state {
        case .signedIn:
            true
        case .signedOut:
            false
        }
    }

    func completePlaceholderSignIn() {
        state = .signedIn(
            user: CurrentUser(
                id: UUID(),
                email: "demo@trainlog.local"
            )
        )
    }

    func signOut() {
        state = .signedOut
    }
}

enum AuthSessionState: Equatable, Sendable {
    case signedOut
    case signedIn(user: CurrentUser)
}

struct CurrentUser: Equatable, Identifiable, Sendable {
    let id: UUID
    let email: String
}
