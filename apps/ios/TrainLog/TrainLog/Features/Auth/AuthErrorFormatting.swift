extension Error {
    var authDisplayMessage: String {
        guard let apiError = self as? APIError else {
            return "Something went wrong. Try again."
        }

        switch apiError {
        case .requestFailed(_, let response):
            return response?.message ?? "Authentication failed."
        case .decodingFailed:
            return "The server response could not be read."
        case .invalidResponse, .invalidURL:
            return "The server response was invalid."
        }
    }
}
