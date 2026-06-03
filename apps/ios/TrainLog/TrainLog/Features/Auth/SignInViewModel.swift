import Foundation
import Observation

@MainActor
@Observable
final class SignInViewModel {
    private let authSession: AuthSession
    private let authRepository: AuthRepository

    var email = ""
    var password = ""
    var viewState: AuthFormViewState = .idle

    init(
        authSession: AuthSession,
        authRepository: AuthRepository
    ) {
        self.authSession = authSession
        self.authRepository = authRepository
    }

    var canSubmit: Bool {
        !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !password.isEmpty &&
        viewState != .submitting
    }

    func signIn() async {
        guard canSubmit else {
            return
        }

        viewState = .submitting

        do {
            let session = try await authRepository.signIn(
                email: email.trimmingCharacters(in: .whitespacesAndNewlines),
                password: password
            )
            authSession.signIn(with: session)
            password = ""
            viewState = .idle
        } catch {
            viewState = .failed(message: error.authDisplayMessage)
        }
    }
}
