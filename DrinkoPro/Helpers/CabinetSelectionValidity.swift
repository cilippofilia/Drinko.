//
//  CabinetSelectionValidity.swift
//  DrinkoPro
//

import Foundation

/// Whether a `CabinetView` selection can still be shown. On iPad, `CabinetView()` and
/// `CabinetView(categoryID:)` can be alive at once with their own selections, so a delete on one
/// page must not leave the other showing a model that's gone. Takes plain IDs so it's testable
/// without a `ModelContext`.
enum CabinetSelectionValidity {
    /// Whether a selected category still exists. `nil` (nothing selected) is always valid.
    static func categoryIsValid(selectedCategoryID: UUID?, categoryIDs: Set<UUID>) -> Bool {
        guard let selectedCategoryID else { return true }
        return categoryIDs.contains(selectedCategoryID)
    }

    /// Whether a selected product still exists and belongs to a category that still exists.
    /// `nil` (nothing selected) is always valid.
    static func productIsValid(
        selectedProductID: UUID?,
        isDeleted: Bool,
        productCategoryID: UUID?,
        categoryIDs: Set<UUID>
    ) -> Bool {
        guard selectedProductID != nil else { return true }
        guard !isDeleted else { return false }
        guard let productCategoryID else { return false }
        return categoryIDs.contains(productCategoryID)
    }
}
