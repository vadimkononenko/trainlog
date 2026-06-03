import Foundation

final class RemoteAuthDataSource {
    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func register(request: RegisterRequest) async throws -> AuthResponseDTO {
        try await apiClient.request(
            AuthResponseDTO.self,
            endpoint: Endpoint(method: .post, path: "/auth/register"),
            body: request
        )
    }

    func login(request: LoginRequest) async throws -> AuthResponseDTO {
        try await apiClient.request(
            AuthResponseDTO.self,
            endpoint: Endpoint(method: .post, path: "/auth/login"),
            body: request
        )
    }

    func refresh(request: RefreshTokenRequest) async throws -> AuthResponseDTO {
        try await apiClient.request(
            AuthResponseDTO.self,
            endpoint: Endpoint(method: .post, path: "/auth/refresh"),
            body: request
        )
    }

    func logout(request: LogoutRequest) async throws {
        try await apiClient.requestVoid(
            endpoint: Endpoint(method: .post, path: "/auth/logout"),
            body: request
        )
    }
}
