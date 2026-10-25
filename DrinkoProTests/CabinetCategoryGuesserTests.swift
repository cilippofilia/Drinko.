import Foundation
import Testing
@testable import DrinkoPro

@Suite("CabinetCategoryGuesser")
struct CabinetCategoryGuesserTests {
    private static func make(_ name: String, _ spirit: MainSpirit) -> CategoryCandidate {
        CategoryCandidate(id: UUID(), name: name, color: spirit.colorName)
    }

    private let vodkas = make("Vodkas", .vodka)
    private let gins = make("Gins", .gin)
    private let whiskeys = make("Whiskeys", .whiskey)
    private let rums = make("Rums", .rum)
    private let tequilas = make("Tequilas & Mezcals", .tequila)
    private let cognacs = make("Cognacs", .cognac)
    private let liqueurs = make("Liqueurs", .liqueur)

    private var suggested: [CategoryCandidate] {
        [vodkas, gins, whiskeys, rums, tequilas, cognacs, liqueurs]
    }

    @Test
    func nameKeywordPicksCategory() {
        #expect(CabinetCategoryGuesser.guess(bottle: "Tanqueray gin", among: suggested) == .match(gins))
        #expect(CabinetCategoryGuesser.guess(bottle: "Havana Club rum", among: suggested) == .match(rums))
    }

    @Test
    func brandKeywordPicksCategory() {
        #expect(CabinetCategoryGuesser.guess(bottle: "Campari", among: suggested) == .match(liqueurs))
    }

    @Test
    func twoCandidatesMeansUnsure() {
        let amari = CategoryCandidate(id: UUID(), name: "Amari", color: MainSpirit.liqueur.colorName)
        let guess = CabinetCategoryGuesser.guess(bottle: "Campari", among: suggested + [amari])
        #expect(guess == .ambiguous([liqueurs, amari]))
    }

    @Test
    func colorDoesNotOverrideAnotherSpiritsName() {
        let skyVodkas = CategoryCandidate(id: UUID(), name: "Vodkas", color: MainSpirit.liqueur.colorName)
        let others = [gins, whiskeys, rums]
        #expect(CabinetCategoryGuesser.guess(bottle: "Campari", among: others + [skyVodkas]) == .unknown)
    }

    @Test
    func unknownBrandIsUnsure() {
        #expect(CabinetCategoryGuesser.guess(bottle: "Hendrick's", among: suggested) == .unknown)
    }

    @Test
    func renamedCategoryMatchesByColor() {
        let mine = CategoryCandidate(id: UUID(), name: "Il mio gin", color: MainSpirit.gin.colorName)
        let others = [vodkas, whiskeys, rums]
        #expect(CabinetCategoryGuesser.guess(bottle: "Tanqueray gin", among: others + [mine]) == .match(mine))
    }

    @Test
    func nonEnglishCategoryName() {
        let liquori = CategoryCandidate(id: UUID(), name: "Liquori", color: MainSpirit.liqueur.colorName)
        #expect(CabinetCategoryGuesser.guess(bottle: "Aperol", among: [vodkas, gins, liquori]) == .match(liquori))
    }

    @Test
    func duplicateIgnoresCaseAndAccents() {
        #expect(CabinetCategoryGuesser.isDuplicate("campari ", in: ["Campari"]))
        #expect(CabinetCategoryGuesser.isDuplicate("Chartreuse", in: ["chartreuse"]))
        #expect(CabinetCategoryGuesser.isDuplicate("Crème de cassis", in: ["creme de cassis"]))
        #expect(!CabinetCategoryGuesser.isDuplicate("Aperol", in: ["Campari"]))
    }

    @Test
    func modelAnswerMapsToCandidate() {
        #expect(ModelCategoryGuesser.candidate(forAnswer: "gins", among: suggested) == gins)
        #expect(ModelCategoryGuesser.candidate(forAnswer: " Rums ", among: suggested) == rums)
        #expect(ModelCategoryGuesser.candidate(forAnswer: "unsure", among: suggested) == nil)
        #expect(ModelCategoryGuesser.candidate(forAnswer: "Bitters", among: suggested) == nil)
    }
}
