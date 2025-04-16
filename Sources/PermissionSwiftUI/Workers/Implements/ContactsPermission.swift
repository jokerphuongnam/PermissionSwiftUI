import Contacts

@available(iOS 9.0, *)
public struct ContactsPermission: PermissionWorker {
    let entityType: CNEntityType
    private let name: String
    
    public init(for entityType: CNEntityType, name: String = "Contacts") {
        self.entityType = entityType
        self.name = name
    }

    public var authorize: AuthorizedPermission {
        get async throws {
            let status = CNContactStore.authorizationStatus(for: entityType)

            switch status {
            case .notDetermined:
                let store = CNContactStore()
                
                let granted = try await store.requestAccess(for: entityType)
                if granted {
                    return .fullPermission
                } else {
                    throw PermissionError.denied(permissionName: name)
                }
            case .authorized:
                return .fullPermission
            case .denied:
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
}
