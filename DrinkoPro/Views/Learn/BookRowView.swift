//
//  BookRowView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 28/06/2023.
//

import SwiftUI

struct BookRowView: View {
    @Environment(\.horizontalSizeClass) var sizeClass

    @State private var rowHeight: CGFloat = 45
    @State private var corners: CGFloat = 10

    var book: Book

    var body: some View {
        NavigationLink(destination: BookDetailView(book: book)) {
            HStack(spacing: sizeClass == .compact ? 10 : 20) {
                AsyncImage(url: URL(string: book.image)) { phase in
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
                    Text(book.title)
                        .font(.headline)

                    Text("© \(book.author)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
        .frame(height: rowHeight)
    }
}

#if DEBUG
#Preview {
    BookRowView(book: .example)
}
#endif
