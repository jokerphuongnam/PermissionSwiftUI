import PushKit

@available(iOS 8.0, *)
public struct VoipPermission: PermissionWorker {
    let queue: DispatchQueue
    let desiredPushTypes: Set<PKPushType>
    private let name: String
    
    public init(queue: DispatchQueue, desiredPushTypes: Set<PKPushType>, name: String = "PushKit (VoIP)") {
        self.queue = queue
        self.desiredPushTypes = desiredPushTypes
        self.name = name
    }
    
    public var authorize: AuthorizedPermission {
        get async throws {
            let registry = PKPushRegistry(queue: queue)
            registry.desiredPushTypes = desiredPushTypes
            
            if registry.desiredPushTypes == desiredPushTypes {
                return .fullPermission
            } else {
                throw PermissionError.restricted(permissionName: name)
            }
        }
    }
}
