import UserNotifications

@available(iOS 10.0, *)
public struct NotificationPermission: PermissionWorker {
    let options: UNAuthorizationOptions
    private let name: String
    private let retry: Bool
    
    public init(options: UNAuthorizationOptions, name: String = "Notification", retryWhenDeniedOnFirstTime retry: Bool = true) {
        self.options = options
        self.name = name
        self.retry = retry
    }
    
    @MainActor public var authorize: AuthorizedPermission {
        get async throws {
            let status = await authorizationStatus
            switch status {
            case .notDetermined:
                return try await requestPermission()
            case .denied:
                if retry {
                    return try await requestPermission()
                }
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
    
    private func requestPermission() async throws -> AuthorizedPermission {
        let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: options)
        if granted {
            throw PermissionError.denied(permissionName: name)
        }
        return .fullPermission
    }
}
