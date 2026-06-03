enum AuthFormViewState: Equatable, Sendable {
    case idle
    case submitting
    case failed(message: String)
}
