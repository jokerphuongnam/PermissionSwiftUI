import SwiftUI

private struct PermissionPresentAlertViewModifier<S, AlertActions, AlertMessage>: ViewModifier where S: StringProtocol,AlertActions: View, AlertMessage: View {
    @Binding private var isPresented: Bool
    private let titleKey: S
    private let permissionState: PermissionState
    private let alertActions: (Result<AuthorizedPermission, PermissionError>) -> AlertActions
    private let alertMessage: ((Result<AuthorizedPermission, PermissionError>) -> AlertMessage)?
    
    init(
        isPresented: Binding<Bool>,
        titleKey: S,
        permissionState: PermissionState,
        alertActions: @escaping (Result<AuthorizedPermission, PermissionError>) -> AlertActions,
        alertMessage: ((Result<AuthorizedPermission, PermissionError>) -> AlertMessage)?
    ) {
        self._isPresented = isPresented
        self.titleKey = titleKey
        self.permissionState = permissionState
        self.alertActions = alertActions
        self.alertMessage = alertMessage
    }
    
    func body(content: Content) -> some View {
        switch permissionState {
        case .notDetermined:
            content
        case .authorized(let authorized):
            if let alertMessage {
                content
                    .alert(titleKey, isPresented: _isPresented, presenting: ()) {
                        alertActions(.success(authorized))
                    } message: { _ in
                        alertMessage(.success(authorized))
                    }
            } else {
                content
                    .alert(titleKey, isPresented: _isPresented, presenting: ()) {
                        alertActions(.success(authorized))
                    }
            }
        case .failure(let error):
            content
                .alert(isPresented: _isPresented, error: error) {
                    alertActions(.failure(error))
                }
        }
    }
}

extension View {
    func alert<S, AlertActions, AlertMessage>(
        isPresented: Binding<Bool>,
        titleKey: S,
        permissionState: PermissionState,
        alertActions: @escaping (Result<AuthorizedPermission, PermissionError>) -> AlertActions,
        alertMessage: ((Result<AuthorizedPermission, PermissionError>) -> AlertMessage)? = nil
    ) -> some View where S: StringProtocol, AlertActions: View, AlertMessage: View {
        modifier(
            PermissionPresentAlertViewModifier(
                isPresented: isPresented,
                titleKey: titleKey,
                permissionState: permissionState,
                alertActions: alertActions,
                alertMessage: alertMessage
            )
        )
    }
}
