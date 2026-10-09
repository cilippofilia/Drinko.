//
//  CabinetSelectionTests.swift
//  DrinkoProTests
//

import Foundation
import Testing
@testable import DrinkoPro

@Suite("CabinetSelectionValidity")
struct CabinetSelectionValidityTests {
    private let categoryA = UUID()
    private let categoryB = UUID()

    @Test func noSelectedCategoryIsAlwaysValid() {
        #expect(CabinetSelectionValidity.categoryIsValid(selectedCategoryID: nil, categoryIDs: []))
    }

    @Test func selectedCategoryStillInSetIsValid() {
        #expect(CabinetSelectionValidity.categoryIsValid(
            selectedCategoryID: categoryA,
            categoryIDs: [categoryA, categoryB]
        ))
    }

    @Test func selectedCategoryNoLongerInSetIsInvalid() {
        #expect(!CabinetSelectionValidity.categoryIsValid(
            selectedCategoryID: categoryA,
            categoryIDs: [categoryB]
        ))
    }

    @Test func noSelectedProductIsAlwaysValid() {
        #expect(CabinetSelectionValidity.productIsValid(
            selectedProductID: nil,
            isDeleted: false,
            productCategoryID: nil,
            categoryIDs: []
        ))
    }

    @Test func selectedProductInLiveCategoryIsValid() {
        #expect(CabinetSelectionValidity.productIsValid(
            selectedProductID: UUID(),
            isDeleted: false,
            productCategoryID: categoryA,
            categoryIDs: [categoryA, categoryB]
        ))
    }

    @Test func deletedProductIsInvalid() {
        #expect(!CabinetSelectionValidity.productIsValid(
            selectedProductID: UUID(),
            isDeleted: true,
            productCategoryID: categoryA,
            categoryIDs: [categoryA]
        ))
    }

    @Test func productWhoseCategoryWasCascadeDeletedIsInvalid() {
        // The category was deleted (cascading to its products), but the product's own
        // `isDeleted` flag may not have flipped yet in memory — the category check still
        // catches it.
        #expect(!CabinetSelectionValidity.productIsValid(
            selectedProductID: UUID(),
            isDeleted: false,
            productCategoryID: categoryA,
            categoryIDs: [categoryB]
        ))
    }

    @Test func productWithNoCategoryIsInvalid() {
        #expect(!CabinetSelectionValidity.productIsValid(
            selectedProductID: UUID(),
            isDeleted: false,
            productCategoryID: nil,
            categoryIDs: [categoryA]
        ))
    }
}
