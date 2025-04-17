import CoreBluetooth

@available(iOS 13.1, *)
public final class BluetoothPermission: NSObject, PermissionWorker {
    private var sessionContinuation: CheckedContinuation<AuthorizedPermission, Error>?
    private let name: String
    private let retry: Bool
    
    public init(name: String = "Bluetooth", retryWhenDeniedOnFirstTime retry: Bool = true) {
        self.name = name
        self.retry = retry
        super.init()
    }
    
    public var authorize: AuthorizedPermission {
        get async throws {
            let auth = CBManager.authorization
            
            switch auth {
            case .notDetermined:
                return try await requestPermission()
            case .denied:
                if retry {
                    return try await requestPermission()
                }
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
    
    private func requestPermission() async throws -> AuthorizedPermission {
        let manager = CBCentralManager()
        manager.delegate = self
        return try await withCheckedThrowingContinuation { [weak self] continuation in
            guard let self else { return }
            self.sessionContinuation = continuation
        }
    }
}

extension BluetoothPermission: @preconcurrency CBCentralManagerDelegate {
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
