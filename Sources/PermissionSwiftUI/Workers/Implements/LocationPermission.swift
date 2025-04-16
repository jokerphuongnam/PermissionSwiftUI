import CoreLocation

public enum LocationPermissionType {
    case location
    case locationWhenInUse
    case locationAlways
}

@available(iOS 14.0, *)
public final class LocationPermission: NSObject, PermissionWorker, @preconcurrency CLLocationManagerDelegate {
    let location: LocationPermissionType
    private let name: String
    private let manager = CLLocationManager()
    private var sessionContinuation: CheckedContinuation<AuthorizedPermission, Error>?
    
    public init(for location: LocationPermissionType, name: String = "Location") {
        self.location = location
        self.name = name
        super.init()
        manager.delegate = self
    }

    public var authorize: AuthorizedPermission {
        get async throws {
            let status = manager.authorizationStatus

            switch status {
            case .notDetermined:
                return try await withCheckedThrowingContinuation { [weak self] continuation in
                    guard let self else {
                        continuation.resume(throwing: PermissionError.unknown)
                        return
                    }
                    self.sessionContinuation = continuation
                    switch self.location {
                    case .location:
                        manager.requestLocation()
                    case .locationWhenInUse:
                        manager.requestWhenInUseAuthorization()
                    case .locationAlways:
                        manager.requestAlwaysAuthorization()
                    }
                }

            case .denied:
                throw PermissionError.denied(permissionName: name)
            case .restricted:
                throw PermissionError.restricted(permissionName: name)
            case .authorizedWhenInUse:
                return .limited
            case .authorizedAlways:
                return .fullPermission
            @unknown default:
                throw PermissionError.unknown
            }
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        sessionContinuation?.resume(throwing: PermissionError.underlying(permissionName: name, error: error))
        sessionContinuation = nil
    }

    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        print(manager.authorizationStatus, manager.authorizationStatus.rawValue)
        switch manager.authorizationStatus {
        case .authorizedWhenInUse:
            sessionContinuation?.resume(returning: .limited)
            sessionContinuation = nil
        case .authorizedAlways:
            sessionContinuation?.resume(returning: .fullPermission)
            sessionContinuation = nil
        case .denied:
            sessionContinuation?.resume(throwing: PermissionError.denied(permissionName: name))
            sessionContinuation = nil
        case .restricted:
            sessionContinuation?.resume(throwing: PermissionError.restricted(permissionName: name))
            sessionContinuation = nil
        default:
            sessionContinuation?.resume(throwing: PermissionError.unknown)
            sessionContinuation = nil
        }
    }
}
