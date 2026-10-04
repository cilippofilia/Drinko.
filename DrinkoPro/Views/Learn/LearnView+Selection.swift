//
//  LearnView+Selection.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 26/09/2026.
//

import Foundation

extension LearnView {
    /// The item shown in the detail column of the Learn split view.
    enum Selection: Hashable, Identifiable {
        case lesson(Lesson)
        case book(Book)
        case abvCalculator
        case superjuice(String)

        /// A stable string identity, used for recents and persistence.
        var id: String {
            switch self {
            case .lesson(let lesson): "lesson:\(lesson.id)"
            case .book(let book): "book:\(book.id)"
            case .abvCalculator: "abv"
            case .superjuice(let juiceType): "superjuice:\(juiceType)"
            }
        }
    }
}
