import CoreNFC
import Foundation

@available(iOS 11.0, *)
public final class NFCPermission: NSObject, PermissionWorker {
    let alertMessage: String
    private let name: String
    private var sessionContinuation: CheckedContinuation<AuthorizedPermission, Error>?
    
    public init(alertMessage: String, name: String = "NFC") {
        self.alertMessage = alertMessage
        self.name = name
    }
    
    public var authorize: AuthorizedPermission {
        get async throws {
            guard NFCNDEFReaderSession.readingAvailable else {
                throw PermissionError.denied(permissionName: name)
            }
            return try await withCheckedThrowingContinuation { [weak self] continuation in
                guard let self else { return }
                self.sessionContinuation = continuation
                let session = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: true)
                session.alertMessage = alertMessage
                session.begin()
            }
        }
    }
}

extension NFCPermission: @preconcurrency NFCNDEFReaderSessionDelegate {
    public func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        sessionContinuation?.resume(throwing: PermissionError.underlying(permissionName: name, error: error))
        sessionContinuation = nil
    }
    
    public func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        sessionContinuation?.resume(returning: .fullPermission)
        sessionContinuation = nil
    }
}
