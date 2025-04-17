import EventKit

@MainActor public func RemindersPermission(for entityType: EKEntityType, name: String = "Reminders", retryWhenDeniedOnFirstTime retry: Bool = true) -> EventKitPermission {
    .init(for: entityType, name: name, retryWhenDeniedOnFirstTime: retry)
}

@MainActor public func CalendarPermission(for entityType: EKEntityType, name: String = "Calendar", retryWhenDeniedOnFirstTime retry: Bool = true) -> EventKitPermission {
    .init(for: entityType, name: name, retryWhenDeniedOnFirstTime: retry)
}

@available(iOS 6.0, *)
public struct EventKitPermission: PermissionWorker {
    let entityType: EKEntityType
    private let name: String
    private let retry: Bool
    
    init(for entityType: EKEntityType, name: String = "Reminders", retryWhenDeniedOnFirstTime retry: Bool = true) {
        self.entityType = entityType
        self.name = name
        self.retry = retry
    }

    public var authorize: AuthorizedPermission {
        get async throws {
            let status = EKEventStore.authorizationStatus(for: entityType)

            switch status {
            case .notDetermined:
                return try await requestPermission()
            case .authorized:
                if retry {
                    return try await requestPermission()
                }
                return .fullPermission
            case .denied:
                throw PermissionError.denied(permissionName: name)

            case .restricted:
                throw PermissionError.restricted(permissionName: name)
            case .fullAccess:
                return .fullPermission
            case .writeOnly:
                return .limited
            @unknown default:
                throw PermissionError.unknown
            }
        }
    }
    
    private func requestPermission() async throws -> AuthorizedPermission {
        let store = EKEventStore()
        return try await withCheckedThrowingContinuation { continuation in
            store.requestAccess(to: entityType) { granted, error in
                if let error = error {
                    continuation.resume(throwing: PermissionError.underlying(permissionName: name, error: error))
                } else if granted {
                    continuation.resume(returning: .fullPermission)
                } else {
                    continuation.resume(throwing: PermissionError.denied(permissionName: name))
                }
            }
        }
    }
}
