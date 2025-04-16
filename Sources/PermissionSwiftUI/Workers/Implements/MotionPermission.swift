import CoreMotion

public struct MotionPermission: PermissionWorker {
    let from: Date
    let to: Date
    private let queue: OperationQueue
    private let name: String
    private let completion: ((_ activities: [CMMotionActivity]) -> Void)?

    public init(from: Date, to: Date, queue: OperationQueue, name: String = "Motion & Fitness", completion: ((_ activities: [CMMotionActivity]) -> Void)?) {
        self.from = from
        self.to = to
        self.queue = queue
        self.name = name
        self.completion = completion
    }

    public var authorize: AuthorizedPermission {
        get async throws {
            let status = CMMotionActivityManager.authorizationStatus()

            switch status {
            case .notDetermined:
                let manager = CMMotionActivityManager()
                return try await withCheckedThrowingContinuation { continuation in
                    manager.queryActivityStarting(from: from, to: to, to: .main) { activities, error in
                        if let error {
                            continuation.resume(throwing: PermissionError.underlying(permissionName: name, error: error))
                        } else if let activities {
                            completion?(activities)
                            continuation.resume(returning: .fullPermission)
                        } else {
                            continuation.resume(returning: .fullPermission)
                        }
                    }
                }

            case .authorized:
                return .fullPermission
            case .denied:
                throw PermissionError.denied(permissionName: name)

            case .restricted:
                throw PermissionError.restricted(permissionName: name)

            @unknown default:
                throw PermissionError.unknown
            }
        }
    }
}
