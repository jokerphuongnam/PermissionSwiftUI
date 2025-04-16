import Speech

@available(iOS 10.0, *)
public struct SpeechPermission: PermissionWorker {
    private let name: String

    public init(name: String = "Speech Recognition") {
        self.name = name
    }

    public var authorize: AuthorizedPermission {
        get async throws {
            let status = SFSpeechRecognizer.authorizationStatus()
            switch status {
            case .notDetermined:
                return try await withCheckedThrowingContinuation { continuation in
                    SFSpeechRecognizer.requestAuthorization { newStatus in
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
