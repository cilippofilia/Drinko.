//
//  SyrupRowView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 08/11/2023.
//

import SwiftUI

struct SyrupRowView: View {
    @Environment(\.horizontalSizeClass) var sizeClass

    @State private var rowHeight: CGFloat = 45
    @State private var corners: CGFloat = 10

    var syrup: Syrup

    var body: some View {
        NavigationLink(destination: SyrupDetailView(syrup: syrup)) {
            HStack(spacing: sizeClass == .compact ? 10 : 20) {
                AsyncImage(url: URL(string: syrup.image)) { phase in
                    switch phase {
                        case .failure:
                            imageFailedToLoad
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                        default:
                            ProgressView()
                    }
                }
                .frame(width: rowHeight,
                       height: rowHeight)
                .cornerRadius(corners)

                VStack(alignment: .leading) {
                    Text(syrup.title)
                        .font(.headline)

                    Text(syrup.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                        .truncationMode(.tail)
                }
            }
        }
        .frame(height: rowHeight)
    }
}

#if DEBUG
#Preview {
    SyrupRowView(syrup: .example)
}
#endif
