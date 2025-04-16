import SwiftUI

@MainActor
private struct RequestPermissionAlertViewModifier<P, S, AlertActions, AlertMessage>: ViewModifier where P: PermissionWorker, S: StringProtocol, AlertActions: View, AlertMessage: View {
    @StateObject fileprivate var observable: PermissionObservableObject<P>
    @StateObject fileprivate var coordinator: PermissionCoordinator = .init()
    fileprivate let titleKey: S
    fileprivate let alertActions: (Result<AuthorizedPermission, PermissionError>) -> AlertActions
    fileprivate let alertMessage: ((Result<AuthorizedPermission, PermissionError>) -> AlertMessage)?

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
            .alert(
                isPresented: $coordinator.isPresented,
                titleKey: titleKey,
                permissionState: observable.permissionState,
                alertActions: alertActions,
                alertMessage: alertMessage
            )
    }
}

@MainActor
extension View {
    public func requestPermission<P, S, AlertActions, AlertMessage>(_ permission: P, _ titleKey: S, @ViewBuilder alertActions: @escaping (Result<AuthorizedPermission, PermissionError>) -> AlertActions, @ViewBuilder alertMessage: @escaping (Result<AuthorizedPermission, PermissionError>) -> AlertMessage) -> some View where P: PermissionWorker, S: StringProtocol, AlertActions: View, AlertMessage: View {
        modifier(
            RequestPermissionAlertViewModifier(
                observable: .init(worker: permission),
                titleKey: titleKey,
                alertActions: alertActions,
                alertMessage: alertMessage
            )
        )
    }
    
    public func requestPermission<P, S, AlertActions>(_ permission: P, _ titleKey: S, @ViewBuilder alertActions: @escaping (Result<AuthorizedPermission, PermissionError>) -> AlertActions) -> some View where P: PermissionWorker, S: StringProtocol, AlertActions: View {
        modifier(
            RequestPermissionAlertViewModifier<P, S, AlertActions, Never>(
                observable: .init(worker: permission),
                titleKey: titleKey,
                alertActions: alertActions,
                alertMessage: nil
            )
        )
    }
}
