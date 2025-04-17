import Photos

@available(iOS 14, *)
public struct PhotoLibraryPermission: PermissionWorker {
    let accessLevel: PHAccessLevel
    private let name: String
    private let retry: Bool
    
    public init(for accessLevel: PHAccessLevel, name: String = "Photo Library", retryWhenDeniedOnFirstTime retry: Bool = true) {
        self.accessLevel = accessLevel
        self.name = name
        self.retry = retry
    }

    public var authorize: AuthorizedPermission {
        get async throws {
            try await requestPermission(status: PHPhotoLibrary.authorizationStatus(), isFirstTime: true)
        }
    }
    
    private func requestPermission(status: PHAuthorizationStatus, isFirstTime: Bool) async throws -> AuthorizedPermission {
        switch status {
        case .notDetermined:
            let newStatus = await PHPhotoLibrary.requestAuthorization(for: accessLevel)
            return try await requestPermission(status: newStatus, isFirstTime: false)
        case .restricted:
            throw PermissionError.restricted(permissionName: name)
        case .denied:
            if isFirstTime && retry {
                return try await requestPermission(status: status, isFirstTime: false)
            }
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
