//
//  LearnView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 22/04/2023.
//

import SwiftUI

struct LearnView: View {
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
                            LearnRowView(lesson: lesson)
                        }
                    }
                }

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
    }
}

#if DEBUG
struct LearnView_Previews: PreviewProvider {
    static var previews: some View {
        LearnView()
    }
}
#endif
