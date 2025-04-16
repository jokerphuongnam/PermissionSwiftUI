import Foundation

@MainActor final class PermissionObservableObject<P>: ObservableObject, Sendable where P: PermissionWorker {
    private let worker: P
    @Published var permissionState: PermissionState = .notDetermined
    
    init(worker: P) {
        self.worker = worker
    }
    
    func requestPermission() {
        let worker = self.worker
        Task.detached(priority: .background) { [weak self] in
            guard let self else { return }
            do {
                let permission = try await worker.authorize
                await MainActor.run { @MainActor [weak self] in
                    guard let self else { return }
                    self.permissionState = .authorized(permission)
                }
            } catch let error as PermissionError {
                await MainActor.run { @MainActor [weak self] in
                    guard let self else { return }
                    self.permissionState = .failure(error: error)
                }
            }
        }
    }
}
