import UIKit

public struct CarPlayPermission: PermissionWorker {
    private let name: String
    
    public init(name: String = "CarPlay") {
        self.name = name
    }
    
    public var authorize: AuthorizedPermission {
        get async throws {
            if await UIDevice.current.userInterfaceIdiom.isCarPlay {
                return .fullPermission
            } else {
                throw PermissionError.denied(permissionName: name)
            }
        }
    }
}

private extension UIUserInterfaceIdiom {
    var isCarPlay: Bool {
        if #available(iOS 14.0, *) {
            return self == .carPlay
        }
        return false
    }
}
