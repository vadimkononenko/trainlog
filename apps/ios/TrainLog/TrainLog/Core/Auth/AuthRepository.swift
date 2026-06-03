import Foundation

protocol AuthRepository {
    func signIn(email: String, password: String) async throws -> AuthStoredSession
    func signUp(email: String, password: String) async throws -> AuthStoredSession
    func restoreSession() async throws -> AuthStoredSession?
    func signOut() async throws
}

final class DefaultAuthRepository: AuthRepository {
    private let remoteDataSource: RemoteAuthDataSource
    private let tokenStore: TokenStore

    init(
        remoteDataSource: RemoteAuthDataSource,
        tokenStore: TokenStore
    ) {
        self.remoteDataSource = remoteDataSource
        self.tokenStore = tokenStore
    }

    func signIn(email: String, password: String) async throws -> AuthStoredSession {
        let response = try await remoteDataSource.login(
            request: LoginRequest(email: email, password: password)
        )
        let session = response.toStoredSession()

        try await tokenStore.save(session)

        return session
    }

    func signUp(email: String, password: String) async throws -> AuthStoredSession {
        let response = try await remoteDataSource.register(
            request: RegisterRequest(email: email, password: password)
        )
        let session = response.toStoredSession()

        try await tokenStore.save(session)

        return session
    }

    func restoreSession() async throws -> AuthStoredSession? {
        try await tokenStore.currentSession()
    }

    func signOut() async throws {
        let credentials = try await tokenStore.currentCredentials()

        if let refreshToken = credentials?.refreshToken {
            try? await remoteDataSource.logout(
                request: LogoutRequest(refreshToken: refreshToken)
            )
        }

        try await tokenStore.clear()
    }
}
