import LocalAuthentication

@available(iOS 8.0, *)
public struct BiometricPermission: PermissionWorker, Sendable {
    let policy: LAPolicy
    let localizedReason: String
    private let name: String
    private let retry: Bool
    
    public init(policy: LAPolicy, localizedReason: String, name: String = "Biometric", retryWhenDeniedOnFirstTime retry: Bool = true) {
        self.policy = policy
        self.localizedReason = localizedReason
        self.name = name
        self.retry = retry
    }

    public var authorize: AuthorizedPermission {
        get async throws {
            let context = LAContext()
            var error: NSError?

            if context.canEvaluatePolicy(policy, error: &error) {
                return try await requestPermission(context)
            } else if let laError = error {
                if laError.code == LAError.biometryNotAvailable.rawValue {
                    throw PermissionError.restricted(permissionName: name)
                } else if laError.code == LAError.biometryNotEnrolled.rawValue {
                    if retry {
                        return try await requestPermission(context)
                    }
                    throw PermissionError.denied(permissionName: name)
                } else {
                    throw PermissionError.underlying(permissionName: name, error: laError)
                }
            } else {
                throw PermissionError.unknown
            }
        }
    }
    
    private func requestPermission(_ context: LAContext) async throws -> AuthorizedPermission {
        return try await withCheckedThrowingContinuation { continuation in
            context.evaluatePolicy(policy, localizedReason: localizedReason) { success, authError in
                if let authError = authError {
                    continuation.resume(throwing: PermissionError.underlying(permissionName: name, error: authError))
                } else if success {
                    continuation.resume(returning: .fullPermission)
                } else {
                    continuation.resume(throwing: PermissionError.denied(permissionName: name))
                }
            }
        }
    }
}
