import Vapor

struct PaginatedResponseDTO<Item: Content & Sendable>: Content, Sendable {
    let items: [Item]
    let metadata: PaginationMetadataDTO
}

struct PaginationMetadataDTO: Content, Sendable {
    let page: Int
    let limit: Int
    let total: Int
    let hasNextPage: Bool
}

