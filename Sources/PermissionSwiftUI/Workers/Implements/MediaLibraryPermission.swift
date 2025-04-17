import MediaPlayer

@available(iOS 9.3, *)
public struct MediaLibraryPermission: PermissionWorker {
    let name: String
    let retry: Bool

    public init(name: String = "Media Library", retryWhenDeniedOnFirstTime retry: Bool = true) {
        self.name = name
        self.retry = retry
    }

    public var authorize: AuthorizedPermission {
        get async throws {
            let status = MPMediaLibrary.authorizationStatus()
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
            @unknown default:
                throw PermissionError.unknown
            }
        }
    }
    
    private func requestPermission() async throws -> AuthorizedPermission {
        let newStatus = try await withCheckedThrowingContinuation { continuation in
            MPMediaLibrary.requestAuthorization { status in
                continuation.resume(returning: status)
            }
        }
        switch newStatus {
        case .authorized:
            return .fullPermission
        case .denied:
            throw PermissionError.denied(permissionName: name)
        case .restricted:
            throw PermissionError.restricted(permissionName: name)
        default:
            throw PermissionError.unknown
        }
    }
}
