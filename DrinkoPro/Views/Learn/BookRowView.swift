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
            if sizeClass == .compact {
                compactBookRow
            } else {
                regularBookRow
            }
        }
        .frame(height: sizeClass == .compact ? rowHeight : rowHeight * 2)
    }

    var compactBookRow: some View {
        HStack {
            Image(book.image)
                .resizable()
                .scaledToFill()
                .frame(width: rowHeight, height: rowHeight)
                .cornerRadius(corners)

            VStack(alignment: .leading) {
                Text(book.title)
                    .font(.headline)

                Text("© \(book.author)")
                    .font(.subheadline)
                    .bold()
                    .foregroundColor(.secondary)
            }
        }
        .frame(height: rowHeight)
    }

    var regularBookRow: some View {
        HStack(spacing: 20) {
            Image(book.image)
                .resizable()
                .scaledToFill()
                .frame(width: rowHeight * 1.75, height: rowHeight * 1.75)
                .cornerRadius(corners * 1.75)

            VStack(alignment: .leading) {
                Text(book.title)
                    .font(.title.bold())

                Text("© \(book.author)")
                    .font(.system(.headline,
                                  design: .default,
                                  weight: .semibold))
                    .foregroundColor(.secondary)
            }
        }
        .frame(height: rowHeight)
    }
}

#Preview {
    BookRowView(book: .example)
}
