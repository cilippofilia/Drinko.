//
//  BooksSection.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 20/04/2024.
//

import SwiftUI

struct BooksSection: View {
    @State private var books = Bundle.main.decode([Book].self, from: "books.json")
    @State private var isCollapsed: Bool = false
    
    var body: some View {
        Section {
            ForEach(books) { book in
                BookRowView(book: book)
            }
        } header: {
            HStack {
                Image(systemName: "chevron.down")
                    .rotationEffect(Angle(degrees: isCollapsed ? -90 : 0))
                    .animation(.spring(.snappy), value: isCollapsed)
                Text("Books")
            }
            .onTapGesture {
                isCollapsed.toggle()
                if isCollapsed {
                    books = [books[0]]
                } else {
                    books = Bundle.main.decode([Book].self, from: "books.json")
                }
            }
        }
    }
}

#Preview {
    BooksSection()
}
