import MediaPlayer

@available(iOS 9.3, *)
public struct MediaLibraryPermission: PermissionWorker {
    let name: String

    public init(name: String = "Media Library") {
        self.name = name
    }

    public var authorize: AuthorizedPermission {
        get async throws {
            let status = MPMediaLibrary.authorizationStatus()
            switch status {
            case .notDetermined:
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

            case .authorized:
                return .fullPermission
            case .denied:
                throw PermissionError.denied(permissionName: name)
            case .restricted:
                throw PermissionError.restricted(permissionName: name)
            @unknown default:
                throw PermissionError.unknown
            }
        }
    }
}
