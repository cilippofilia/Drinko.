//
//  LearnView+Selection.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 26/09/2026.
//

import Foundation

extension LearnView {
    enum Selection: Hashable, Identifiable {
        case lesson(Lesson)
        case book(Book)

        /// Persisted in recents, so keep it stable.
        var id: String {
            switch self {
            case .lesson(let lesson): "lesson:\(lesson.id)"
            case .book(let book): "book:\(book.id)"
            }
        }
    }
}
