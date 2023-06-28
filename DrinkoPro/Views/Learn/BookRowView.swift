//
//  BookRowView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 28/06/2023.
//

import SwiftUI

struct BookRowView: View {
    var book: Book

    var body: some View {
        NavigationLink(destination: BookDetailView(book: book)) {
            HStack {
                Image(book.image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 45, height: 45)
                    .cornerRadius(10)

                VStack(alignment: .leading, spacing: 6) {
                    Text(book.title)
                        .font(.headline)

                    Text("© \(book.author)")
                        .font(.subheadline)
                        .bold()
                        .foregroundColor(.secondary)
                }
            }
            .frame(height: 45)
        }
    }
}

#if DEBUG
struct BookRowView_Previews: PreviewProvider {
    static var previews: some View {
        BookRowView(book: .example)
    }
}
#endif
