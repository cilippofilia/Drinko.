//
//  BookRowView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 28/06/2023.
//

import SwiftUI

struct BookRowView: View {
    @Environment(\.horizontalSizeClass) var sizeClass
    @ScaledMetric private var scaledRowHeight: CGFloat = rowHeight

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
            .frame(width: scaledRowHeight,
                   height: scaledRowHeight)
            .cornerRadius(imageCornerRadius)
            .accessibilityHidden(true)

            VStack(alignment: .leading) {
                Text(book.title)
                    .font(.headline)

                Text("© \(book.author)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .frame(minHeight: scaledRowHeight)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(book.title)
        .accessibilityValue("By \(book.author)")
    }
}

#if DEBUG
#Preview {
    BookRowView(book: .example)
}
#endif
