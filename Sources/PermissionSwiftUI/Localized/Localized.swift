open class Localized {
    init() {}
    
    func getErrorDescription(error: PermissionError) -> String {
        switch error {
        case .unknown:
            "Unknown permission error"
        case .restricted(let worker):
            "\(worker) access was restricted"
        case .denied(let worker):
            "\(worker) access was denied"
        case .underlying(let worker, let error):
            "\(worker) error: \(error.localizedDescription)"
        }
    }
}

public extension Localized {
    nonisolated(unsafe) static var shared: Localized = .init()
}
