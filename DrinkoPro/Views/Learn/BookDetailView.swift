//
//  BookDetailView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 28/06/2023.
//

import SwiftUI

struct BookDetailView: View {
    @Environment(\.horizontalSizeClass) var sizeClass
    @State private var frameHeight: CGFloat = 280
    @State private var corners: CGFloat = 10

    var book: Book

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            if sizeClass == .compact {
                compactBookView
            } else {
                regularBookView
            }
        }
        .navigationBarTitle(book.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    var compactBookView: some View {
        VStack {
            Image(book.image)
                .resizable()
                .scaledToFill()
                .frame(width: compactScreenWidth)
                .clipped()

            VStack(spacing: 10) {
                Text(book.title)
                    .font(.title.bold())

                Text(book.description)
                    .font(.headline)
                    .foregroundColor(.secondary)

                Text(book.summary)
            }
            .frame(maxWidth: compactScreenWidth)
            .padding(.bottom)
        }
    }

    var regularBookView: some View {
        VStack(spacing: 20) {
            Image(book.image)
                .resizable()
                .scaledToFit()
                .frame(width: compactScreenWidth,
                       height: frameHeight * 1.75)
                .clipped()

            VStack(spacing: 20) {
                Text(book.title)
                    .font(.title.bold())
                    .padding(.vertical)

                Text(book.description)
                    .font(.headline)
                    .foregroundColor(.secondary)

                Text(book.summary)
            }
            .frame(maxWidth: compactScreenWidth)
            .padding(.bottom)
        }
    }
}

#if DEBUG
#Preview {
    BookDetailView(book: .example)
}
#endif
