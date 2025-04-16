import SwiftUI

public enum Presented {
    @available(macOS, unavailable)
    @available(iOS 14.0, tvOS 14.0, watchOS 7.0, *)
    case fullScreenCover
    
    @available(macOS, unavailable)
    @available(iOS 14.0, tvOS 14.0, watchOS 7.0, *)
    case sheet
    
    @available(iOS 13.0, macOS 10.15, *)
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    case popover(attachmentAnchor: PopoverAttachmentAnchor = .rect(.bounds), arrowEdge: Edge? = nil)
}
