//
//  ItemRowViewModel.swift
//  Drinko
//
//  Created by Filippo Cilia on 25/04/2021.
//

import Foundation

extension ItemRowView {
    class ViewModel: ObservableObject {
        let family: Family
        let item: Item

        var name: String {
            item.itemName
        }

        init(family: Family, item: Item) {
            self.family = family
            self.item = item
        }
    }
}
