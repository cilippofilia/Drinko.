import SwiftUI

extension View {
    /// Before iOS 26, toolbar labels show only their icon, so this shows the title instead.
    @ViewBuilder
    func titleOnlyBeforeGlassToolbars() -> some View {
        if #available(iOS 26, macOS 26, *) {
            self
        } else {
            labelStyle(.titleOnly)
        }
    }
}
