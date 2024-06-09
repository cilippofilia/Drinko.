//
//  CocktailsViewModelTests.swift
//  DrinkoProTests
//
//  Created by Filippo Cilia on 19/05/2024.
//

import XCTest
@testable import DrinkoPro

final class CocktailsViewModelTests: XCTestCase {
    var viewModel: CocktailsViewModel!

    override func setUpWithError() throws {
        viewModel = CocktailsViewModel()
    }

    override func tearDownWithError() throws {
        viewModel = nil
    }

    func testSortFromAtoZ() {
        viewModel.sortOption = .fromAtoZ
        let sortedCocktails = viewModel.sortedCocktails
        XCTAssertEqual(sortedCocktails, sortedCocktails.sorted { $0.name < $1.name })
    }

    func testSortFromZtoA() {
        viewModel.sortOption = .fromZtoA
        let sortedCocktails = viewModel.sortedCocktails
        XCTAssertEqual(sortedCocktails, sortedCocktails.sorted { $1.name < $0.name })
    }

    func testSortByGlass() {
        viewModel.sortOption = .byGlass
        let sortedCocktails = viewModel.sortedCocktails
        XCTAssertEqual(sortedCocktails, sortedCocktails.sorted { $0.glass < $1.glass })
    }

    func testSortByIce() {
        viewModel.sortOption = .byIce
        let sortedCocktails = viewModel.sortedCocktails
        XCTAssertEqual(sortedCocktails, sortedCocktails.sorted { $0.ice < $1.ice })
    }

    func testFilterCocktails() {
        viewModel.searchText = "Margarita"
        let filteredCocktails = viewModel.filteredCocktails
        for cocktail in filteredCocktails {
            XCTAssertTrue(cocktail.name.localizedCaseInsensitiveContains("Margarita"))
        }
    }

    func testGetSuggestedCocktails() {
        let cocktail = viewModel.listOfCocktails.first!
        let ingredient = cocktail.ingredients.first!.name
        let suggestedCocktails = viewModel.getsSuggestedCocktails(with: ingredient, from: cocktail)
        XCTAssertTrue(suggestedCocktails.count <= 5)
        for suggested in suggestedCocktails {
            XCTAssertFalse(suggested.id == cocktail.id)
            XCTAssertTrue(suggested.ingredients.contains { $0.name.contains(ingredient) })
        }
    }
}
