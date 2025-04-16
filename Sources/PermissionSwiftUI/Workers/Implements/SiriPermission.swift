import Intents

@available(iOS 10.0, *)
public struct SiriPermission: PermissionWorker {
    let name: String

    public init(name: String = "Siri") {
        self.name = name
    }

    public var authorize: AuthorizedPermission {
        get async throws {
            let status = INPreferences.siriAuthorizationStatus()

            switch status {
            case .notDetermined:
                return try await withCheckedThrowingContinuation { continuation in
                    INPreferences.requestSiriAuthorization { newStatus in
                        switch newStatus {
                        case .authorized:
                            continuation.resume(returning: .fullPermission)
                        case .denied:
                            continuation.resume(throwing: PermissionError.denied(permissionName: name))
                        case .restricted:
                            continuation.resume(throwing: PermissionError.restricted(permissionName: name))
                        default:
                            continuation.resume(throwing: PermissionError.unknown)
                        }
                    }
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
