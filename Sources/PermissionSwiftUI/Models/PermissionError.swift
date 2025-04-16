import Foundation

public enum PermissionError: Error, Sendable {
    case unknown
    case restricted(permissionName: String)
    case denied(permissionName: String)
    case underlying(permissionName: String, error: Error)
}

extension PermissionError: LocalizedError {
    public var errorDescription: String? {
        Localized.shared.getErrorDescription(error: self)
    }
}
