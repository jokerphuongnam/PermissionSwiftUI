import Photos

@available(iOS 14, *)
public struct PhotoLibraryPermission: PermissionWorker {
    let accessLevel: PHAccessLevel
    private let name: String
    
    public init(for accessLevel: PHAccessLevel, name: String = "Photo Library") {
        self.accessLevel = accessLevel
        self.name = name
    }

    public var authorize: AuthorizedPermission {
        get async throws {
            try await asyncRequests(status: PHPhotoLibrary.authorizationStatus())
        }
    }
    
    private func asyncRequests(status: PHAuthorizationStatus) async throws -> AuthorizedPermission {
        switch status {
        case .notDetermined:
            let newStatus = await PHPhotoLibrary.requestAuthorization(for: accessLevel)
            return try await asyncRequests(status: newStatus)
        case .restricted:
            throw PermissionError.restricted(permissionName: name)
        case .denied:
            throw PermissionError.denied(permissionName: name)
        case .authorized:
            return AuthorizedPermission.fullPermission
        case .limited:
            return AuthorizedPermission.limited
        @unknown default:
            throw PermissionError.unknown
        }
    }
}
