actor TokenStore {
    private var credentials: AuthCredentials?

    func save(_ credentials: AuthCredentials) {
        self.credentials = credentials
    }

    func currentCredentials() -> AuthCredentials? {
        credentials
    }

    func clear() {
        credentials = nil
    }
}

struct AuthCredentials: Equatable, Sendable {
    let accessToken: String
    let refreshToken: String
}
