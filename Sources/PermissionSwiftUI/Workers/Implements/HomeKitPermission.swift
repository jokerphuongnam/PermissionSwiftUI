import HomeKit

@available(iOS 8.0, *)
public final class HomeKitPermission: NSObject, PermissionWorker, @preconcurrency HMHomeManagerDelegate {
    private let name: String
    private var continuation: CheckedContinuation<AuthorizedPermission, Error>?
    private let queue: DispatchQueue

    public init(queue: DispatchQueue, name: String = "HomeKit") {
        self.name = name
        self.queue = queue
    }

    public var authorize: AuthorizedPermission {
        get async throws {
            return try await withCheckedThrowingContinuation { [weak self] continuation in
                guard let self else { return }
                self.continuation = continuation
                let manager = HMHomeManager()
                manager.delegate = self

                queue.asyncAfter(deadline: .now() + 3.0) { [weak self, weak manager] in
                    guard let self, let manager else { return }
                    continuation.resume(throwing: PermissionError.restricted(permissionName: self.name))
                    manager.delegate = nil
                }
            }
        }
    }

    public func homeManagerDidUpdateHomes(_ manager: HMHomeManager) {
        continuation?.resume(returning: .fullPermission)
        continuation = nil
    }
}
