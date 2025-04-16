import AVFoundation

@available(iOS 7.0, *)
public struct CameraPermission: PermissionWorker {
    private let name: String
    let mediaType: AVMediaType
    
    public init(for mediaType: AVMediaType, name: String = "Camera") {
        self.name = name
        self.mediaType = mediaType
    }
    
    public var authorize: AuthorizedPermission {
        get async throws {
            let status = AVCaptureDevice.authorizationStatus(for: mediaType)
            switch status {
            case .notDetermined:
                let granted = await AVCaptureDevice.requestAccess(for: mediaType)
                if granted {
                    return .fullPermission
                } else {
                    throw PermissionError.denied(permissionName: name)
                }
            case .restricted:
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
}
