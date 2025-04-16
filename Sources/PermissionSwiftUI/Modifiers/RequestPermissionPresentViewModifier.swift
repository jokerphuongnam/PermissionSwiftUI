import SwiftUI

private struct RequestPermissionPresentViewModifier<P, Authorized, Failure>: ViewModifier where P: PermissionWorker, Authorized: View, Failure: View {
    @StateObject fileprivate var observable: PermissionObservableObject<P>
    @StateObject fileprivate var coordinator: PermissionCoordinator = .init()
    fileprivate let presented: Presented
    fileprivate let onDismiss: (() -> Void)?
    fileprivate let authorized: (AuthorizedPermission) -> Authorized
    fileprivate let failure: (_ error: PermissionError) -> Failure
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                observable.requestPermission()
            }
            .onReceive(observable.$permissionState) { result in
                switch result {
                case .notDetermined:
                    observable.requestPermission()
                    coordinator.isPresented = false
                case .authorized:
                    coordinator.isPresented = true
                case .failure:
                    coordinator.isPresented = true
                }
            }
            .permissionPresent(
                presented: presented,
                isPresented: $coordinator.isPresented,
                onDismiss: onDismiss
            ) {
                switch observable.permissionState {
                case .notDetermined:
                    EmptyView()
                case .authorized(let authorized):
                    self.authorized(authorized)
                case .failure(let error):
                    failure(error)
                }
            }
    }
}

extension View {
    public func requestPermission<P, Authorized, Failure>(
        _ permission: P,
        with presented: Presented = .sheet,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder authorized: @escaping (AuthorizedPermission) -> Authorized,
        @ViewBuilder failure: @escaping (_ error: PermissionError) -> Failure
    ) -> some View where P: PermissionWorker, Authorized: View, Failure: View  {
        modifier(
            RequestPermissionPresentViewModifier(
                observable: .init(worker: permission),
                presented: presented,
                onDismiss: onDismiss,
                authorized: authorized,
                failure: failure
            )
        )
    }
    
    public func requestPermission<P, Authorized>(
        _ permission: P,
        with presented: Presented = .sheet,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder authorized: @escaping (AuthorizedPermission) -> Authorized
    ) -> some View where P: PermissionWorker, Authorized: View  {
        modifier(
            RequestPermissionPresentViewModifier(
                observable: .init(worker: permission),
                presented: presented,
                onDismiss: onDismiss,
                authorized: authorized,
                failure: { _ in
                    EmptyView()
                }
            )
        )
    }
    
    public func requestPermission<P, Failure>(
        _ permission: P,
        with presented: Presented = .sheet,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder failure: @escaping (_ error: PermissionError) -> Failure
    ) -> some View where P: PermissionWorker, Failure: View  {
        modifier(
            RequestPermissionPresentViewModifier(
                observable: .init(worker: permission),
                presented: presented,
                onDismiss: onDismiss,
                authorized: { _ in EmptyView() },
                failure: failure
            )
        )
    }
}
