import CoreBluetooth

@available(iOS 13.1, *)
public final class BluetoothPermission: NSObject, PermissionWorker, @preconcurrency CBCentralManagerDelegate {
    private var sessionContinuation: CheckedContinuation<AuthorizedPermission, Error>?
    private let name: String
    
    public init(name: String = "Bluetooth") {
        self.name = name
        super.init()
    }

    public var authorize: AuthorizedPermission {
        get async throws {
            let auth = CBManager.authorization

            switch auth {
            case .notDetermined:
                let manager = CBCentralManager()
                manager.delegate = self
                return try await withCheckedThrowingContinuation { [weak self] continuation in
                    guard let self else { return }
                    self.sessionContinuation = continuation
                }
            case .denied:
                throw PermissionError.denied(permissionName: name)

            case .restricted:
                throw PermissionError.restricted(permissionName: name)

            case .allowedAlways:
                return .fullPermission
            @unknown default:
                throw PermissionError.unknown
            }
        }
    }
    
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        let status = CBManager.authorization
        switch status {
        case .allowedAlways:
            sessionContinuation?.resume(returning: .fullPermission)
        case .denied:
            sessionContinuation?.resume(throwing: PermissionError.denied(permissionName: name))
        case .restricted:
            sessionContinuation?.resume(throwing: PermissionError.restricted(permissionName: name))
        default:
            sessionContinuation?.resume(throwing: PermissionError.unknown)
        }
    }
}
