//
//  IconsView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 10/02/2024.
//

import SwiftUI

struct IconsView: View {
    @Environment(\.horizontalSizeClass) var sizeClass
    @Environment(IconModel.self) var iconModel: IconModel
    @State private var isSelected: Bool = false

    let columns = Array(repeating: GridItem(.adaptive(minimum: 114, maximum: 1024), spacing: 0), count: 3)

    var body: some View {
        VStack {
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(Icon.allCases) { icon in
                        VStack(spacing: 0) {
                            Button {
                                iconModel.setAlternateAppIcon(icon: icon)
                                isSelected.toggle()
                            } label: {
                                IconImage(icon: icon)
                            }
                            
                            Image(systemName: icon.id == iconModel.appIcon.rawValue ? "checkmark.circle" : "circle")
                                .font(.title)
                                .foregroundStyle(icon.id == iconModel.appIcon.rawValue ? Color.secondary : Color.clear)
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

#Preview {
    NavigationStack {
        IconsView()
            .environment(IconModel())
    }
}
