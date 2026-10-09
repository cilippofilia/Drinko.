//
//  CabinetSelectionValidity.swift
//  DrinkoPro
//

import Foundation

/// Whether a `CabinetView` selection is still something that can be shown. On iPad, `CabinetView()`
/// and `CabinetView(categoryID:)` can both be alive at once (every visited `Tab` stays alive in
/// `TabView`), each owning its own `selectedProduct`/`selectedCategory`. Deleting a product or
/// category on one page must not leave the other page's `navigationDestination(item:)` showing
/// a model that's gone.
///
/// Takes plain IDs rather than the SwiftData models themselves, so it's pure and testable
/// without a `ModelContext`.
enum CabinetSelectionValidity {
    /// Whether a selected category still exists. `nil` (nothing selected) is always valid.
    static func categoryIsValid(selectedCategoryID: UUID?, categoryIDs: Set<UUID>) -> Bool {
        guard let selectedCategoryID else { return true }
        return categoryIDs.contains(selectedCategoryID)
    }

    /// Whether a selected product still exists and belongs to a category that still exists.
    /// `nil` (nothing selected) is always valid; a deleted product (directly, or via its
    /// category's cascade delete) or one with no surviving category is not.
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
