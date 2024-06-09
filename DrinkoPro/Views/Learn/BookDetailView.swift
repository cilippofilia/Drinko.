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
        ScrollView {
            if sizeClass == .compact {
                compactBookView
            } else {
                regularBookView
            }
        }
        .navigationBarTitle(book.title)
        .navigationBarTitleDisplayMode(.inline)
        .scrollIndicators(.hidden, axes: .vertical)
        .scrollBounceBehavior(.basedOnSize)

    }

    var compactBookView: some View {
        VStack {
            AsyncImage(url: URL(string: book.image)) { state in
                switch state {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure:
                    imageFailedToLoad
                @unknown default:
                    EmptyView()
                }
            }
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
            AsyncImage(url: URL(string: book.image)) { state in
                switch state {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure:
                    imageFailedToLoad
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: compactScreenWidth)
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
