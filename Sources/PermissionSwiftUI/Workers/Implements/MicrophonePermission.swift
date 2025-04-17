import AVFoundation

@available(iOS, introduced: 8.0)
public struct MicrophonePermission: PermissionWorker {
    private let name: String
    private let retry: Bool
    
    public init(name: String = "Microphone", retryWhenDeniedOnFirstTime retry: Bool = true) {
        self.name = name
        self.retry = retry
    }
    
    public var authorize: AuthorizedPermission {
        get async throws {
            if #available(iOS 17.0, *) {
                let status = AVAudioApplication.shared.recordPermission
                switch status {
                case .undetermined:
                    return try await requestPermissioniOS17()
                case .denied:
                    if retry {
                        return try await requestPermissioniOS17()
                    }
                    throw PermissionError.denied(permissionName: name)
                case .granted:
                    return .fullPermission
                @unknown default:
                    throw PermissionError.unknown
                }
            } else {
                let status = AVAudioSession.sharedInstance().recordPermission
                switch status {
                case .undetermined:
                    return try await requestPermissionUnderiOS17()
                case .denied:
                    if retry {
                        return try await requestPermissionUnderiOS17()
                    }
                    throw PermissionError.denied(permissionName: name)
                case .granted:
                    return .fullPermission
                @unknown default:
                    throw PermissionError.unknown
                }
            }
        }
    }
    
    @available(iOS 17.0, *)
    private func requestPermissioniOS17() async throws -> AuthorizedPermission {
        let granted = await AVAudioApplication.requestRecordPermission()
        if granted {
            return .fullPermission
        } else {
            throw PermissionError.denied(permissionName: name)
        }
    }
    
    private func requestPermissionUnderiOS17() async throws -> AuthorizedPermission {
        return try await withCheckedThrowingContinuation { continuation in
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                if granted {
                    continuation.resume(returning: .fullPermission)
                } else {
                    continuation.resume(throwing: PermissionError.denied(permissionName: name))
                }
            }
        }
    }
}
