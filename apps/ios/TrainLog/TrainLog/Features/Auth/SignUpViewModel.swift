import Foundation
import Observation

@MainActor
@Observable
final class SignUpViewModel {
    private let authSession: AuthSession
    private let authRepository: AuthRepository

    var email = ""
    var password = ""
    var confirmPassword = ""
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
        password.count >= 8 &&
        password == confirmPassword &&
        viewState != .submitting
    }

    func signUp() async {
        guard canSubmit else {
            viewState = .failed(message: validationMessage)
            return
        }

        viewState = .submitting

        do {
            let session = try await authRepository.signUp(
                email: email.trimmingCharacters(in: .whitespacesAndNewlines),
                password: password
            )
            authSession.signIn(with: session)
            password = ""
            confirmPassword = ""
            viewState = .idle
        } catch {
            viewState = .failed(message: error.authDisplayMessage)
        }
    }

    private var validationMessage: String {
        if password.count < 8 {
            return "Password must contain at least 8 characters."
        }

        if password != confirmPassword {
            return "Passwords do not match."
        }

        return "Enter an email and password."
    }
}
