//
//  LearnView+Selection.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 26/09/2026.
//

import Foundation

extension LearnView {
    /// The item shown in the detail column of the Learn split view.
    enum Selection: Hashable {
        case lesson(Lesson)
        case book(Book)
        case abvCalculator
        case superjuice(String)
    }
}
