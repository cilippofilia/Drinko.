//
//  BookRowView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 28/06/2023.
//

import SwiftUI

struct BookRowView: View {
    @Environment(\.horizontalSizeClass) var sizeClass

    var book: Book

    var body: some View {
        HStack(spacing: sizeClass == .compact ? 10 : 20) {
            AsyncImage(url: URL(string: book.image)) { state in
                switch state {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure:
                    ImageFailedToLoad()
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: rowHeight,
                   height: rowHeight)
            .cornerRadius(imageCornerRadius)

            VStack(alignment: .leading) {
                Text(book.title)
                    .font(.headline)

                Text("© \(book.author)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
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
