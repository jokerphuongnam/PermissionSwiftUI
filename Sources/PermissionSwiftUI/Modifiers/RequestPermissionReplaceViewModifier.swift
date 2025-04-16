import SwiftUI

private struct RequestPermissionReplaceViewModifier<P, Authorized, Failure>: ViewModifier where P: PermissionWorker, Authorized: View, Failure: View {
    @StateObject fileprivate var observable: PermissionObservableObject<P>
    fileprivate let authorized: (AuthorizedPermission) -> Authorized
    fileprivate let failure: (_ error: PermissionError) -> Failure
    
    func body(content: Content) -> some View {
        switch observable.permissionState {
        case .notDetermined:
            content
                .onAppear {
                    observable.requestPermission()
                }
        case .authorized(let authorized):
            self.authorized(authorized)
        case .failure(let error):
            failure(error)
        }
    }
}

extension View {
    public func requestPermission<P, Authorized, Failure>(
        _ permission: P,
        @ViewBuilder authorized: @escaping (AuthorizedPermission) -> Authorized,
        @ViewBuilder failure: @escaping (_ error: PermissionError) -> Failure
    ) -> some View where P: PermissionWorker, Authorized: View, Failure: View  {
        modifier(
            RequestPermissionReplaceViewModifier(
                observable: .init(worker: permission),
                authorized: authorized,
                failure: failure
            )
        )
    }
    
    public func requestPermission<P, Authorized>(
        _ permission: P,
        @ViewBuilder authorized: @escaping (AuthorizedPermission) -> Authorized
    ) -> some View where P: PermissionWorker, Authorized: View {
        modifier(
            RequestPermissionReplaceViewModifier(
                observable: .init(worker: permission),
                authorized: authorized,
                failure: { _ in
                    EmptyView()
                }
            )
        )
    }
    
    public func requestPermission<P, Failure>(
        _ permission: P,
        @ViewBuilder failure: @escaping (_ error: PermissionError) -> Failure
    ) -> some View where P: PermissionWorker, Failure: View  {
        modifier(
            RequestPermissionReplaceViewModifier(
                observable: .init(worker: permission),
                authorized: { _ in EmptyView() },
                failure: failure
            )
        )
    }
}
