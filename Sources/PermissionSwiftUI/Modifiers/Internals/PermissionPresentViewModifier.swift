import SwiftUI

private struct PermissionPresentViewModifier<PresentedContent>: ViewModifier where PresentedContent: View {
    let presented: Presented
    @Binding var isPresented: Bool
    let onDismiss: (() -> Void)?
    let presentedContent: () -> PresentedContent
    
    init(presented: Presented, isPresented: Binding<Bool>, onDismiss: (() -> Void)?, content presentedContent: @escaping () -> PresentedContent) {
        self.presented = presented
        self._isPresented = isPresented
        self.onDismiss = onDismiss
        self.presentedContent = presentedContent
    }

    func body(content: Content) -> some View {
        switch presented {
        case .fullScreenCover:
            content
                .fullScreenCover(isPresented: _isPresented, onDismiss: onDismiss, content: presentedContent)
        case .sheet:
            content
                .sheet(isPresented: _isPresented, onDismiss: onDismiss, content: presentedContent)
        case .popover(let attachmentAnchor, let arrowEdge):
            content
                .popover(isPresented: _isPresented, attachmentAnchor: attachmentAnchor, arrowEdge: arrowEdge, content: presentedContent)
        }
    }
}

extension View {
    @ViewBuilder func permissionPresent<Content>(
        presented: Presented,
        isPresented: Binding<Bool>,
        onDismiss: (() -> Void)?,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View where Content: View {
        modifier(PermissionPresentViewModifier(presented: presented, isPresented: isPresented, onDismiss: onDismiss, content: content))
    }
}
