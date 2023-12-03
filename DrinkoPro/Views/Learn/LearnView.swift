//
//  LearnView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 22/04/2023.
//

import SwiftUI

struct LearnView: View {
    static let learnTag: String? = "Learn"

    @StateObject var viewModel = AdvancedViewModel()
    @State private var isCollapsed = false
    
    let basics = Bundle.main.decode([Lesson].self, from: "basics.json")
    let spirits = Bundle.main.decode([Spirit].self, from: "spirits.json")
    let syrups = Bundle.main.decode([Syrup].self, from: "syrups.json")
    let books = Bundle.main.decode([Book].self, from: "books.json")

    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Basics")) {
                    ForEach(basics) { lesson in
                        LessonRowView(lesson: lesson)
                    }
                }
                
                Section(header: Text("Spirits")) {
                    ForEach(spirits) { spirit in
                        SpiritRowView(spirit: spirit)
                    }
                }
                
                Section(header: Text("Syrups")) {
                    ForEach(syrups) { syrup in
                        SyrupRowView(syrup: syrup)
                    }
                }
                
                Section(header: Text("Calculators")) {
                    SuperjuiceRowView(juiceType: "lime")
                    SuperjuiceRowView(juiceType: "lemon")
                    ABVRowView()
                }
                
                Section(header: Text("Books")) {
                    ForEach(books) { book in
                        BookRowView(book: book)
                    }
                }
            }
            .navigationTitle("Learn")
            .onAppear {
                viewModel.fetchJSON()
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

#Preview {
    LearnView()
}
