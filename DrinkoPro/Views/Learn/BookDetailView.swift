//
//  BookDetailView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 28/06/2023.
//

import SwiftUI

struct BookDetailView: View {
    @Environment(\.horizontalSizeClass) var sizeClass

    var book: Book

    private var isCompact: Bool { sizeClass == .compact }

    var body: some View {
        ScrollView {
            VStack(spacing: isCompact ? nil : 20) {
                CachedRemoteImage(url: URL(string: book.image), contentMode: .fill)
                    .frame(height: imageFrameHeight)
                    #if os(macOS)
                    .frame(width: screenWidth)
                    #else
                    .frame(minWidth: 0, maxWidth: .infinity)
                    #endif
                    .clipped()

                VStack(spacing: isCompact ? 10 : 20) {
                    Text(book.title)
                        .font(.title.bold())
                        .padding(.vertical, isCompact ? 0 : nil)

                    Text(book.description)
                        .font(.headline)
                        .foregroundStyle(.secondary)

                    Text(book.summary)
                }
                .padding(.horizontal)
                .padding(.bottom)
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
