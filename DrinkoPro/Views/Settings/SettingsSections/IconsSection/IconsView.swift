//
//  IconsView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 10/02/2024.
//

import SwiftUI

struct IconsView: View {
    @Environment(\.horizontalSizeClass) var sizeClass
    @Environment(DrinkoIcons.self) var icons: DrinkoIcons
    @State private var isSelected: Bool = false

    let columns = Array(repeating: GridItem(.adaptive(minimum: 114, maximum: 1024), spacing: 0), count: 3)

    var body: some View {
        VStack {
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(Icon.allCases) { icon in
                        VStack(spacing: 0) {
                            Button {
                                icons.setAlternateAppIcon(icon: icon)
                                isSelected.toggle()
                            } label: {
                                IconImage(icon: icon)
                            }
                            
                            Image(systemName: UIApplication.shared.alternateIconName == icon.id ? "checkmark.circle" : "circle")
                                .font(.title)
                                .foregroundStyle(UIApplication.shared.alternateIconName == icon.id ? Color.secondary : Color.clear)
                                .symbolEffect(.bounce.up, value: isSelected)
                        }
                    }
                }
            }
            .navigationTitle("App icon")
            .scrollIndicators(.hidden, axes: .vertical)
            .scrollBounceBehavior(.basedOnSize)
        }
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        IconsView()
            .environment(DrinkoIcons())
    }
}
#endif
