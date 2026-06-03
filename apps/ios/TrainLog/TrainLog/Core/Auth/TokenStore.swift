import Foundation
import Security

actor TokenStore {
    private let service = "com.vadymkononenko.TrainLog.auth"
    private let account = "session"
    private let persistsToKeychain: Bool

    private var cachedSession: AuthStoredSession?

    init(
        cachedSession: AuthStoredSession? = nil,
        persistsToKeychain: Bool = true
    ) {
        self.cachedSession = cachedSession
        self.persistsToKeychain = persistsToKeychain
    }

    func save(_ session: AuthStoredSession) throws {
        cachedSession = session

        guard persistsToKeychain else {
            return
        }

        let data = try encode(session)
        let query = baseQuery()
        let attributes: [String: Any] = [
            kSecValueData as String: data
        ]

        let updateStatus = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        guard updateStatus != errSecSuccess else {
            return
        }

        guard updateStatus == errSecItemNotFound else {
            throw TokenStoreError.keychainWriteFailed(updateStatus)
        }

        var addQuery = query
        addQuery[kSecValueData as String] = data
        addQuery[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly

        let addStatus = SecItemAdd(addQuery as CFDictionary, nil)
        guard addStatus == errSecSuccess else {
            throw TokenStoreError.keychainWriteFailed(addStatus)
        }
    }

    func currentSession() throws -> AuthStoredSession? {
        if let cachedSession {
            return cachedSession
        }

        guard persistsToKeychain else {
            return nil
        }

        var query = baseQuery()
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        guard status != errSecItemNotFound else {
            return nil
        }

        guard status == errSecSuccess, let data = item as? Data else {
            throw TokenStoreError.keychainReadFailed(status)
        }

        let session = try decodeSession(from: data)
        cachedSession = session

        return session
    }

    func currentCredentials() throws -> AuthCredentials? {
        try currentSession()?.credentials
    }

    func clear() throws {
        cachedSession = nil

        guard persistsToKeychain else {
            return
        }

        let status = SecItemDelete(baseQuery() as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw TokenStoreError.keychainDeleteFailed(status)
        }
    }

    private func baseQuery() -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
    }

    private func encode(_ session: AuthStoredSession) throws -> Data {
        let payload: [String: Any] = [
            "accessToken": session.credentials.accessToken,
            "refreshToken": session.credentials.refreshToken,
            "user": [
                "id": session.user.id.uuidString,
                "email": session.user.email
            ]
        ]

        return try JSONSerialization.data(withJSONObject: payload)
    }

    private func decodeSession(from data: Data) throws -> AuthStoredSession {
        guard
            let payload = try JSONSerialization.jsonObject(with: data) as? [String: Any],
            let accessToken = payload["accessToken"] as? String,
            let refreshToken = payload["refreshToken"] as? String,
            let userPayload = payload["user"] as? [String: Any],
            let userIDString = userPayload["id"] as? String,
            let userID = UUID(uuidString: userIDString),
            let email = userPayload["email"] as? String
        else {
            throw TokenStoreError.invalidStoredSession
        }

        return AuthStoredSession(
            credentials: AuthCredentials(
                accessToken: accessToken,
                refreshToken: refreshToken
            ),
            user: CurrentUser(
                id: userID,
                email: email
            )
        )
    }
}

struct AuthStoredSession: Equatable, Sendable {
    let credentials: AuthCredentials
    let user: CurrentUser
}

struct AuthCredentials: Equatable, Sendable {
    let accessToken: String
    let refreshToken: String
}

enum TokenStoreError: Error, Equatable {
    case keychainReadFailed(OSStatus)
    case keychainWriteFailed(OSStatus)
    case keychainDeleteFailed(OSStatus)
    case invalidStoredSession
}
