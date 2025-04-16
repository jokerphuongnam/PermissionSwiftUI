import UserNotifications

@available(iOS 10.0, *)
public struct NotificationPermission: PermissionWorker {
    let options: UNAuthorizationOptions
    private let name: String
    
    public init(options: UNAuthorizationOptions, name: String = "Notification") {
        self.options = options
        self.name = name
    }
    
    @MainActor public var authorize: AuthorizedPermission {
        get async throws {
            let status = await authorizationStatus
            switch status {
            case .notDetermined:
                let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: options)
                if granted {
                    throw PermissionError.denied(permissionName: name)
                } else {
                    return .fullPermission
                }
            case .denied:
                throw PermissionError.denied(permissionName: name)
            case .authorized:
                return .fullPermission
            case .provisional:
                throw PermissionError.denied(permissionName: name)
            case .ephemeral:
                return .limited
            @unknown default:
                throw PermissionError.unknown
            }
        }
    }
    
    private nonisolated var authorizationStatus: UNAuthorizationStatus {
        get async {
            let center = UNUserNotificationCenter.current()
            return await center.notificationSettings().authorizationStatus
        }
    }
}
