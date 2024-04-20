//
//  LearnView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 22/04/2023.
//

import SwiftUI

struct LearnView: View {
    static let learnTag: String? = "Learn"

    var body: some View {
        NavigationStack {
            List {
                LessonsSection()
                
                SpiritsSection()
                
                SyrupsSection()
                
                CalculatorsSection()
                
                BooksSection()
            }
            .navigationTitle("Learn")
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

#Preview {
    LearnView()
}
