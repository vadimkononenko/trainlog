import Foundation

final class APIClient: Sendable {
    private let baseURL: URL
    private let session: any NetworkSessionProtocol

    init(
        baseURL: URL,
        session: any NetworkSessionProtocol = URLSession.shared
    ) {
        self.baseURL = baseURL
        self.session = session
    }

    /// Sends a JSON request and decodes a JSON response.
    ///
    /// - Parameters:
    ///   - responseType: The expected decoded response type.
    ///   - endpoint: The API endpoint metadata.
    /// - Returns: The decoded response payload.
    func request<Response: Decodable>(
        _ responseType: Response.Type,
        endpoint: Endpoint
    ) async throws -> Response {
        let data = try await data(endpoint: endpoint, body: Optional<EmptyRequestBody>.none)

        do {
            return try JSONDecoder().decode(responseType, from: data)
        } catch {
            throw APIError.decodingFailed
        }
    }

    /// Sends a JSON request with a body and decodes a JSON response.
    ///
    /// - Parameters:
    ///   - responseType: The expected decoded response type.
    ///   - endpoint: The API endpoint metadata.
    ///   - body: The JSON request body.
    /// - Returns: The decoded response payload.
    func request<Response: Decodable, Body: Encodable>(
        _ responseType: Response.Type,
        endpoint: Endpoint,
        body: Body
    ) async throws -> Response {
        let data = try await data(endpoint: endpoint, body: body)

        do {
            return try JSONDecoder().decode(responseType, from: data)
        } catch {
            throw APIError.decodingFailed
        }
    }

    /// Sends a JSON request and expects an empty response body.
    ///
    /// - Parameters:
    ///   - endpoint: The API endpoint metadata.
    func requestVoid(endpoint: Endpoint) async throws {
        _ = try await data(endpoint: endpoint, body: Optional<EmptyRequestBody>.none)
    }

    /// Sends a JSON request with a body and expects an empty response body.
    ///
    /// - Parameters:
    ///   - endpoint: The API endpoint metadata.
    ///   - body: The JSON request body.
    func requestVoid<Body: Encodable>(endpoint: Endpoint, body: Body) async throws {
        _ = try await data(endpoint: endpoint, body: body)
    }

    private func data<Body: Encodable>(
        endpoint: Endpoint,
        body: Body?
    ) async throws -> Data {
        let request = try makeRequest(endpoint: endpoint, body: body)
        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard (200..<300).contains(httpResponse.statusCode) else {
            let errorResponse = try? JSONDecoder().decode(APIErrorResponseDTO.self, from: data)
            throw APIError.requestFailed(
                statusCode: httpResponse.statusCode,
                response: errorResponse
            )
        }

        return data
    }

    private func makeRequest<Body: Encodable>(
        endpoint: Endpoint,
        body: Body?
    ) throws -> URLRequest {
        guard var components = URLComponents(
            url: baseURL.appending(path: endpoint.path),
            resolvingAgainstBaseURL: false
        ) else {
            throw APIError.invalidURL
        }

        if !endpoint.queryItems.isEmpty {
            components.queryItems = endpoint.queryItems
        }

        guard let url = components.url else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        if let body {
            request.httpBody = try JSONEncoder().encode(body)
        }

        return request
    }
}

private struct EmptyRequestBody: Encodable {}
