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
            return try await withCheckedThrowingContinuation { continuation in
                PHPhotoLibrary.requestAuthorization(for: accessLevel) { status in
                    switch status {
                    case .authorized:
                        continuation.resume(returning: .fullPermission)
                    case .limited:
                        continuation.resume(returning: .limited)
                    case .denied:
                        continuation.resume(throwing: PermissionError.denied(permissionName: name))
                    case .restricted:
                        continuation.resume(throwing: PermissionError.restricted(permissionName: name))
                    case .notDetermined:
                        break
                    @unknown default:
                        break
                    }
                }
            }
        case .restricted:
            throw PermissionError.restricted(permissionName: name)
        case .denied:
            if isFirstTime && retry {
                return try await requestPermission(status: .notDetermined, isFirstTime: false)
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
