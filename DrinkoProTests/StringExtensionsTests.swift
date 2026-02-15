import Testing
@testable import DrinkoPro

struct StringExtensionsTests {
    @Test func capitalizingFirstLetter() {
        #expect("hello".capitalizingFirstLetter() == "Hello")
        #expect("".capitalizingFirstLetter() == "")
    }

    @Test func capitalizeFirstLetterMutatesString() {
        var value = "cocktail"
        value.capitalizeFirstLetter()
        #expect(value == "Cocktail")
    }

    @Test func numberOfLinesCountsNewlines() {
        #expect("one".numberOfLines == 1)
        #expect("one\ntwo".numberOfLines == 2)
        #expect("one\ntwo\n".numberOfLines == 3)
    }
}
