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
        ScrollView(.vertical, showsIndicators: false) {
            VStack {
                Image(book.image)
                    .resizable()
                    .scaledToFill()
                    .clipped()

                VStack(spacing: 10) {
                    Text(book.title)
                        .font(.title)
                        .bold()
                        .padding(.vertical)

                    Text(book.description)
                        .font(.headline)
                        .foregroundColor(.secondary)

                    Text(book.summary)
                }
                .frame(maxWidth: screenWidthPlusMargins)
                .padding(.bottom)
            }
        }
        .navigationBarTitle(book.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct BookDetailView_Previews: PreviewProvider {
    static var previews: some View {
        BookDetailView(book: .example)
    }
}
