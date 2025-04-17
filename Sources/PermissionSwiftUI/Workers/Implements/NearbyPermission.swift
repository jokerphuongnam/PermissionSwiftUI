import NearbyInteraction

@available(iOS, introduced: 14.0, deprecated: 16.0)
public struct NearbyPermission: PermissionWorker {
    private let name: String
    
    public init(name: String = "Nearby Interaction") {
        self.name = name
    }

    public var authorize: AuthorizedPermission {
        get async throws {
            return try await withCheckedThrowingContinuation { continuation in
                if NISession.isSupported {
                    continuation.resume(returning: .fullPermission)
                } else {
                    continuation.resume(throwing: PermissionError.restricted(permissionName: name))
                }
            }
        }
    }
}
