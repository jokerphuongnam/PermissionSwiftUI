import AVFoundation

@available(iOS 7.0, *)
public struct CameraPermission: PermissionWorker {
    private let name: String
    let mediaType: AVMediaType
    private let retry: Bool
    
    public init(for mediaType: AVMediaType, name: String = "Camera", retryWhenDeniedOnFirstTime retry: Bool = true) {
        self.name = name
        self.mediaType = mediaType
        self.retry = retry
    }
    
    public var authorize: AuthorizedPermission {
        get async throws {
            let status = AVCaptureDevice.authorizationStatus(for: mediaType)
            switch status {
            case .notDetermined:
                return try await requestPermission()
            case .restricted:
                if retry {
                    return try await requestPermission()
                }
                throw PermissionError.restricted(permissionName: name)
            case .denied:
                throw PermissionError.denied(permissionName: name)
            case .authorized:
                return .fullPermission
            @unknown default:
                throw PermissionError.unknown
            }
        }
    }
    
    private func requestPermission() async throws -> AuthorizedPermission {
        let granted = await AVCaptureDevice.requestAccess(for: mediaType)
        if granted {
            return .fullPermission
        } else {
            throw PermissionError.denied(permissionName: name)
        }
    }
}
