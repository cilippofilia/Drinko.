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

    var body: some View {
        NavigationStack {
            VStack {
                List {
                    ForEach(subjects) { subject in
                        Section(header: Text(subject.name)) {
                            ForEach(subject.lessons) { lesson in
                                LearnRowView(lesson: lesson)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Learn")
        }
    }
}

struct LearnView_Previews: PreviewProvider {
    static var previews: some View {
        LearnView()
    }
}
