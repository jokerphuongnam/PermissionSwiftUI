import HealthKit

@available(iOS 15.0, watchOS 8.0, macOS 13.0, *)
public struct HealthKitPermission: PermissionWorker {
    private let name: String
    let typesToShare: Set<HKSampleType>
    let typesToRead: Set<HKObjectType>
    private let healthStore = HKHealthStore()

    public init(toShare typesToShare: Set<HKSampleType>, toRead typesToRead: Set<HKObjectType>, name: String) {
        self.typesToShare = typesToShare
        self.typesToRead = typesToRead
        self.name = name
    }

    public var authorize: AuthorizedPermission {
        get async throws {
            guard HKHealthStore.isHealthDataAvailable() else {
                throw PermissionError.restricted(permissionName: name)
            }
            do {
                try await healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead)
                return .fullPermission
            } catch {
                throw PermissionError.underlying(permissionName: name, error: error)
            }
        }
    }
}
