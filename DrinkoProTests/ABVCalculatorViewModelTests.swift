import XCTest
@testable import DrinkoPro

@MainActor
final class ABVCalculatorViewModelTests: XCTestCase {
    func testStartsWithOneEmptyIngredient() {
        let viewModel = ABVCalculatorViewModel()

        XCTAssertEqual(viewModel.bottles.count, 1)
        XCTAssertFalse(viewModel.canRemoveIngredients)
    }

    func testDilutionFactorForEveryMethodAndServingCombination() {
        let viewModel = ABVCalculatorViewModel()

        let expected: [Serving: [MixingMethod: Double]] = [
            .up: [.built: 0.0, .stir: 0.25, .shake: 0.3],
            .rocks: [.built: 0.0, .stir: 0.3, .shake: 0.35],
            .crushed: [.built: 0.0, .stir: 0.0, .shake: 0.4]
        ]

        for serving in Serving.allCases {
            for method in MixingMethod.allCases {
                viewModel.serving = serving
                viewModel.method = method

                XCTAssertEqual(
                    viewModel.dilutionFactor,
                    expected[serving]?[method],
                    "serving: \(serving), method: \(method)"
                )
            }
        }
    }

    func testSingleIngredientBuiltUpResult() {
        let viewModel = ABVCalculatorViewModel()
        viewModel.bottles[0].amount = 60
        viewModel.bottles[0].abv = 40
        viewModel.serving = .up
        viewModel.method = .built

        XCTAssertEqual(viewModel.result, 40.0, accuracy: 0.0001)
    }

    func testSingleIngredientStirredUpResult() {
        let viewModel = ABVCalculatorViewModel()
        viewModel.bottles[0].amount = 60
        viewModel.bottles[0].abv = 40
        viewModel.serving = .up
        viewModel.method = .stir

        XCTAssertEqual(viewModel.result, 32.0, accuracy: 0.0001)
    }

    func testMultipleIngredientsResult() {
        let viewModel = ABVCalculatorViewModel()
        viewModel.bottles = [
            Bottle(name: "Gin", amount: 60, abv: 40),
            Bottle(name: "Vermouth", amount: 15, abv: 18)
        ]
        viewModel.serving = .up
        viewModel.method = .built

        let totalVolume = 75.0
        let totalAlcohol = (60.0 * 40.0 / 100.0) + (15.0 * 18.0 / 100.0)
        let expected = totalAlcohol / totalVolume * 100

        XCTAssertEqual(viewModel.result, expected, accuracy: 0.0001)
    }

    func testAllZeroAmountsReturnsZeroNotNaN() {
        let viewModel = ABVCalculatorViewModel()
        viewModel.bottles = [Bottle(), Bottle()]

        XCTAssertEqual(viewModel.result, 0.0, accuracy: 0.0001)
        XCTAssertFalse(viewModel.result.isNaN)
    }

    func testRemoveIngredientUpdatesResult() {
        let viewModel = ABVCalculatorViewModel()
        viewModel.bottles = [
            Bottle(name: "Gin", amount: 60, abv: 40),
            Bottle(name: "Water", amount: 60, abv: 0)
        ]
        viewModel.serving = .up
        viewModel.method = .built

        let idToRemove = viewModel.bottles[1].id
        viewModel.removeIngredient(id: idToRemove)

        XCTAssertEqual(viewModel.bottles.count, 1)
        XCTAssertEqual(viewModel.result, 40.0, accuracy: 0.0001)
    }

    func testRemoveIngredientRefusesToRemoveTheLastOne() {
        let viewModel = ABVCalculatorViewModel()
        let onlyId = viewModel.bottles[0].id

        viewModel.removeIngredient(id: onlyId)

        XCTAssertEqual(viewModel.bottles.count, 1)
    }

    func testAddIngredientAppendsAnEmptyBottle() {
        let viewModel = ABVCalculatorViewModel()

        viewModel.addIngredient()

        XCTAssertEqual(viewModel.bottles.count, 2)
        XCTAssertTrue(viewModel.canRemoveIngredients)
    }

    func testIngredientNumberReflectsPosition() {
        let viewModel = ABVCalculatorViewModel()
        viewModel.addIngredient()

        let firstId = viewModel.bottles[0].id
        let secondId = viewModel.bottles[1].id

        XCTAssertEqual(viewModel.ingredientNumber(for: firstId), 1)
        XCTAssertEqual(viewModel.ingredientNumber(for: secondId), 2)
    }
}
