//
//  LearnDetailView.swift
//  DrinkoPro
//

import SwiftUI

struct LearnDetailView: View {
    let selection: LearnView.Selection

    var body: some View {
        switch selection {
        case .lesson(let lesson):
            LessonDetailView(lesson: lesson)
        case .book(let book):
            BookDetailView(book: book)
        }
    }
}
