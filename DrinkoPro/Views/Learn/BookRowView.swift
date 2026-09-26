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
            CachedRemoteImage(url: URL(string: book.image), contentMode: .fill)
            .frame(width: scaledRowHeight,
                   height: scaledRowHeight)
            .clipShape(.rect(cornerRadius: imageCornerRadius))
            .accessibilityHidden(true)

            VStack(alignment: .leading) {
                Text(book.title)
                    .font(.headline)

                Text("© \(book.author)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
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
