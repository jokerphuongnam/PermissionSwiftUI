import Contacts

@available(iOS 9.0, *)
public struct ContactsPermission: PermissionWorker {
    let entityType: CNEntityType
    private let name: String
    private let retry: Bool
    
    public init(for entityType: CNEntityType, name: String = "Contacts", retryWhenDeniedOnFirstTime retry: Bool = true) {
        self.entityType = entityType
        self.name = name
        self.retry = retry
    }

    public var authorize: AuthorizedPermission {
        get async throws {
            let status = CNContactStore.authorizationStatus(for: entityType)

            switch status {
            case .notDetermined:
                return try await requestPermission()
            case .authorized:
                return .fullPermission
            case .denied:
                if retry {
                    return try await requestPermission()
                }
                throw PermissionError.denied(permissionName: name)
            case .restricted:
                throw PermissionError.restricted(permissionName: name)
            case .limited:
                return .limited
            @unknown default:
                throw PermissionError.unknown
            }
        }
    }
    
    private func requestPermission() async throws -> AuthorizedPermission {
        let store = CNContactStore()
        
        let granted = try await store.requestAccess(for: entityType)
        if granted {
            return .fullPermission
        } else {
            throw PermissionError.denied(permissionName: name)
        }
    }
}
