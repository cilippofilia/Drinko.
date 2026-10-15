//
//  BookDetailView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 28/06/2023.
//

import SwiftUI

struct BookDetailView: View {
    var book: Book

    var body: some View {
        ScrollView {
            VStack {
                CachedRemoteImage(url: URL(string: book.image), contentMode: .fill)
                    #if os(macOS)
                    .frame(width: screenWidth, height: imageFrameHeight)
                    #else
                    .aspectRatio(16 / 9, contentMode: .fill)
                    .frame(maxWidth: .infinity)
                    .frame(maxHeight: heroImageMaxHeight)
                    #endif
                    .clipped()

                VStack {
                    Text(book.title)
                        .font(.title.bold())

                    Text(book.description)
                        .font(.headline)
                        .foregroundStyle(.secondary)

                    Text(book.summary)
                }
                .padding(.horizontal)
                .padding(.bottom)
                .frame(maxWidth: 700)
                .frame(maxWidth: .infinity)
            }
        }
        .navigationTitle(book.title)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .scrollIndicators(.hidden, axes: .vertical)
        .scrollBounceBehavior(.basedOnSize)
    }
}

#if DEBUG
#Preview {
    BookDetailView(book: .example)
}
#endif
