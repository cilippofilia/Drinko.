//
//  LearnDetailView.swift
//  DrinkoPro
//

import SwiftUI

/// The detail column content for a Learn selection.
struct LearnDetailView: View {
    let selection: LearnView.Selection

    var body: some View {
        switch selection {
        case .lesson(let lesson):
            LessonDetailView(lesson: lesson)
        case .book(let book):
            BookDetailView(book: book)
        case .abvCalculator:
            ABVCalculator()
        case .superjuice(let juiceType):
            SuperJuiceView(typeOfJuice: juiceType)
        }
    }
}
