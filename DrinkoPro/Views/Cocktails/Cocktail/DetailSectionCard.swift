//
//  DetailSectionCard.swift
//  DrinkoPro
//

import SwiftUI

struct DetailSectionCard<Content: View>: View {
    let title: LocalizedStringKey
    let isCollapsed: Bool
    let toggle: () -> Void
    @ViewBuilder let content: Content

    @ScaledMetric private var badgeSize: CGFloat = 30

    private let headerMinHeight: CGFloat = 44

    /// Trimmed by how much taller the header is than the badge, so the badge sits as far from the
    /// top edge as from the trailing one.
    private var topInset: CGFloat {
        max(0, detailCardInset - max(0, headerMinHeight - badgeSize) / 2)
    }

    init(
        title: LocalizedStringKey,
        isCollapsed: Bool,
        toggle: @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.isCollapsed = isCollapsed
        self.toggle = toggle
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: detailCardGroupSpacing) {
            Button(action: toggle) {
                HStack {
                    Text(title)
                        .font(.title3.bold())

                    Spacer()

                    Image(systemName: "chevron.down")
                        .bold()
                        .imageScale(.small)
                        .rotationEffect(.degrees(isCollapsed ? -90 : 0))
                        .frame(width: badgeSize, height: badgeSize)
                        .background(.fill.tertiary, in: .circle)
                        .accessibilityHidden(true)
                }
                .frame(minHeight: headerMinHeight)
                .contentShape(.rect)
            }
            .buttonStyle(.plain)
            .accessibilityAddTraits(.isHeader)
            .accessibilityValue(CollapsibleSectionAccessibility.value(isCollapsed: isCollapsed))
            .accessibilityHint(CollapsibleSectionAccessibility.hint(isCollapsed: isCollapsed))

            if !isCollapsed {
                content
            }
        }
        .padding(.horizontal, detailCardInset)
        .padding(.top, topInset)
        .padding(.bottom, detailCardInset)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.fill.quinary, in: .rect(cornerRadius: libraryCardCornerRadius))
    }
}

#if DEBUG
#Preview {
    VStack {
        DetailSectionCard(title: "Ingredients", isCollapsed: false, toggle: { }, content: {
            Text("2 oz. London Dry Gin")
        })
        DetailSectionCard(title: "Procedure", isCollapsed: true, toggle: { }, content: {
            Text("Hidden")
        })
    }
    .padding()
}
#endif
