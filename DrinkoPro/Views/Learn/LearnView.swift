//
//  LearnView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 22/04/2023.
//

import SwiftUI

struct LearnView: View {
    @Environment(\.horizontalSizeClass) var sizeClass
    static let learnTag: String? = "Learn"

    let subjects = Bundle.main.decode([Subject].self, from: "lessons.json")
    let spirits = Bundle.main.decode([Spirit].self, from: "spirits.json")
    let books = Bundle.main.decode([Book].self, from: "books.json")

    var body: some View {
        NavigationStack {
            List {
                ForEach(subjects) { subject in
                    Section(header: Text(subject.name)) {
                        ForEach(subject.lessons) { lesson in
                            LessonRowView(lesson: lesson)
                        }
                    }
                }

                // MARK: SUPERJUICE Section goes here

                Section(header: Text("Spirits")) {
                    ForEach(spirits) { spirit in
                        SpiritRowView(spirit: spirit)
                    }
                }

                Section(header: Text("Books")) {
                    ForEach(books) { book in
                        BookRowView(book: book)
                    }
                }
            }
            .navigationTitle("Learn")
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

private extension LearnView {
    var superjuiceRow: some View {
        NavigationLink(destination: EmptyView()) {
            HStack(spacing: sizeClass == .compact ? 10 : 20) {
                Image("superjuice")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 45,
                           height: 45)
                    .cornerRadius(10)

                VStack(alignment: .leading) {
                    Text("Super Juices Calculator")
                        .font(.headline)

                    Text("Calculate what you need in order to make your beloved super juices.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                        .truncationMode(.tail)
                }
            }
        }
        .frame(height: 45)
    }
}

#Preview {
    LearnView()
}
