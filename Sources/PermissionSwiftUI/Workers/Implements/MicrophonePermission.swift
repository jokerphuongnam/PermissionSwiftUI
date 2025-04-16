import AVFoundation

@available(iOS, introduced: 8.0)
public struct MicrophonePermission: PermissionWorker {
    private let name: String
    
    public init(name: String = "Microphone") {
        self.name = name
    }
    
    public var authorize: AuthorizedPermission {
        get async throws {
            if #available(iOS 17.0, *) {
                let status = AVAudioApplication.shared.recordPermission
                switch status {
                case .undetermined:
                    let granted = await AVAudioApplication.requestRecordPermission()
                    if granted {
                        return .fullPermission
                    } else {
                        throw PermissionError.denied(permissionName: name)
                    }
                case .denied:
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
                    return try await withCheckedThrowingContinuation { continuation in
                        AVAudioSession.sharedInstance().requestRecordPermission { granted in
                            if granted {
                                continuation.resume(returning: .fullPermission)
                            } else {
                                continuation.resume(throwing: PermissionError.denied(permissionName: name))
                            }
                        }
                    }
                case .denied:
                    throw PermissionError.denied(permissionName: name)
                case .granted:
                    return .fullPermission
                @unknown default:
                    throw PermissionError.unknown
                }
            }
        }
    }
}
