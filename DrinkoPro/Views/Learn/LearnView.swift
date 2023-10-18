//
//  LearnView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 22/04/2023.
//

import SwiftUI

struct LearnView: View {
    @Environment(\.horizontalSizeClass) var sizeClass
    @StateObject var proLessons = ProLessonsViewModel()
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

                // TODO: UNCOMMENT WHEN DRINKO PRO IS READY
//                Section(header: Text("Drinko Pro")) {
//                    ForEach(proLessons.lessons) { lesson in
//                        ProLessonRowView(proLesson: lesson)
//                    }
//                }

                Section(header: Text("Superjuice calculators")) {
                    SuperjuiceRowView(juiceType: "Lime")
                    SuperjuiceRowView(juiceType: "Lemon")
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
            .onAppear {
                guard let url = URL(string: "https://raw.githubusercontent.com/cilippofilia/drinko-jsons/main/test.json") else {
                    return
                }
                proLessons.fetchData(from: url)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

#Preview {
    LearnView()
}
