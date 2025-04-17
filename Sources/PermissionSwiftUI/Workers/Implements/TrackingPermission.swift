import AppTrackingTransparency

public struct TrackingPermission: PermissionWorker {
    let name: String
    private let retry: Bool

    public init(name: String = "Tracking", retryWhenDeniedOnFirstTime retry: Bool = true) {
        self.name = name
        self.retry = retry
    }

    public var authorize: AuthorizedPermission {
        get async throws {
            let status = ATTrackingManager.trackingAuthorizationStatus

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
        return try await withCheckedThrowingContinuation { continuation in
            ATTrackingManager.requestTrackingAuthorization { newStatus in
                switch newStatus {
                case .authorized:
                    continuation.resume(returning: .fullPermission)
                case .denied:
                    continuation.resume(throwing: PermissionError.denied(permissionName: name))
                case .restricted:
                    continuation.resume(throwing: PermissionError.restricted(permissionName: name))
                case .notDetermined:
                    continuation.resume(throwing: PermissionError.unknown)
                @unknown default:
                    continuation.resume(throwing: PermissionError.unknown)
                }
            }
        }
    }
}
