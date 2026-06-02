import Vapor

/// Converts thrown route errors into the public TrainLog API error response shape.
struct APIErrorMiddleware: AsyncMiddleware {
    /// Passes successful requests through and converts thrown errors to JSON responses.
    ///
    /// - Parameters:
    ///   - request: The incoming HTTP request.
    ///   - next: The next responder in the middleware chain.
    /// - Returns: The downstream response or a normalized API error response.
    func respond(to request: Request, chainingTo next: any AsyncResponder) async throws -> Response {
        do {
            return try await next.respond(to: request)
        } catch {
            request.logger.report(error: error)
            return try makeErrorResponse(from: error, request: request)
        }
    }

    /// Builds a response that preserves Vapor abort metadata and normalizes the body.
    ///
    /// - Parameters:
    ///   - error: The thrown error to convert.
    ///   - request: The request that produced the error.
    /// - Returns: A JSON response using the public API error format.
    private func makeErrorResponse(from error: any Error, request: Request) throws -> Response {
        let context = makeErrorContext(from: error, request: request)
        let response = Response(status: context.status, headers: context.headers)
        try response.content.encode(APIErrorResponseDTO(
            code: context.code.rawValue,
            message: context.message,
            details: [:]
        ))
        return response
    }

    /// Extracts response metadata from a thrown error.
    ///
    /// - Parameters:
    ///   - error: The thrown error to inspect.
    ///   - request: The request that produced the error.
    /// - Returns: The status, headers, message, and public API error code.
    private func makeErrorContext(from error: any Error, request: Request) -> APIErrorContext {
        if let abort = error as? any AbortError {
            return APIErrorContext(
                status: abort.status,
                headers: abort.headers,
                message: abort.reason,
                code: code(for: abort.status)
            )
        }

        let message = request.application.environment.isRelease
            ? APIErrorMessage.internalServerError
            : String(describing: error)

        return APIErrorContext(
            status: .internalServerError,
            headers: HTTPHeaders(),
            message: message,
            code: .internalServerError
        )
    }

    /// Maps an HTTP status to a stable API error code.
    ///
    /// - Parameter status: The HTTP response status.
    /// - Returns: The API error code consumed by the iOS client.
    private func code(for status: HTTPResponseStatus) -> APIErrorCode {
        switch status {
        case .badRequest:
            .badRequest
        case .unauthorized:
            .unauthorized
        case .forbidden:
            .forbidden
        case .notFound:
            .notFound
        case .conflict:
            .conflict
        case .unprocessableEntity:
            .validationFailed
        default:
            status.code >= 500 ? .internalServerError : .requestFailed
        }
    }
}

private struct APIErrorContext {
    let status: HTTPResponseStatus
    let headers: HTTPHeaders
    let message: String
    let code: APIErrorCode
}

private enum APIErrorCode: String {
    case badRequest = "bad_request"
    case unauthorized
    case forbidden
    case notFound = "not_found"
    case conflict
    case validationFailed = "validation_failed"
    case internalServerError = "internal_server_error"
    case requestFailed = "request_failed"
}

private enum APIErrorMessage {
    static let internalServerError = "Something went wrong."
}
