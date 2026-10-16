import SwiftUI

extension View {
    /// Shows toolbar button titles before iOS 26, where icon-bearing toolbar labels would
    /// otherwise drop their text; iOS 26+ (including iPhone Duo's vertical bar) keeps the icons.
    @ViewBuilder
    func titleOnlyBeforeGlassToolbars() -> some View {
        if #available(iOS 26, macOS 26, *) {
            self
        } else {
            labelStyle(.titleOnly)
        }
    }
}
