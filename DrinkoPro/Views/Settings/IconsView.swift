//
//  IconsView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 10/02/2024.
//

import SwiftUI

struct IconsView: View {
    @Environment(\.horizontalSizeClass) var sizeClass
    
    private let compactColumn = [
        GridItem(.flexible(minimum: 100,
                           maximum: 200),
                 alignment: .center),
        GridItem(.flexible(minimum: 100,
                           maximum: 200),
                 alignment: .center)
    ]

    private let regularColumns = [
        GridItem(.flexible(minimum: 100,
                           maximum: 200),
                 alignment: .center),
        
        GridItem(.flexible(minimum: 100,
                           maximum: 200),
                 alignment: .center),
        
        GridItem(.flexible(minimum: 100,
                           maximum: 200),
                 alignment: .center),
        
        GridItem(.flexible(minimum: 100,
                           maximum: 200),
                 alignment: .center)
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: sizeClass == .compact ? compactColumn : regularColumns,
                      spacing: sizeClass == .compact ? 10 : 20) {
                Text("Replace this with an image")
                    .frame(width: 150, height: 150)
                    .padding()
                    .background(Color.secondary.opacity(0.33))
                    .clipShape(RoundedRectangle(cornerRadius: 25))
            }
        }
        .scrollIndicators(.hidden, axes: .vertical)
        .scrollBounceBehavior(.basedOnSize)
    }
}

#Preview {
    IconsView()
}
