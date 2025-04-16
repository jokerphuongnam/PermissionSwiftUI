import SwiftUI

private struct RequestPermissionCompletionHandlerModifier<P>: ViewModifier where P: PermissionWorker {
    @StateObject fileprivate var observable: PermissionObservableObject<P>
    fileprivate let completion: (Result<AuthorizedPermission, PermissionError>) -> Void
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                observable.requestPermission()
            }
            .onReceive(observable.$permissionState) { result in
                switch result {
                case .notDetermined:
                    observable.requestPermission()
                case .authorized(let permissionType):
                    completion(.success(permissionType))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
}

extension View {
    public func requestPermission<P>(_ permission: P, completion: @escaping (_ result: Result<AuthorizedPermission, PermissionError>) -> Void) -> some View where P: PermissionWorker {
        modifier(
            RequestPermissionCompletionHandlerModifier(
                observable: .init(worker: permission),
                completion: completion
            )
        )
    }
}
