//
//  BottleStyle.swift
//  DrinkoPro
//

import Foundation

/// A bottle a bartender wouldn't swap for another. Recipe ingredients and cabinet bottles both resolve
/// to a style, so "Cointreau" and "triple sec" count as the same bottle.
nonisolated enum BottleStyle: String, CaseIterable, Sendable {
    // Case order sets precedence: the first style with a matching fragment wins, so a specific
    // fragment ("extra dry") must belong to an earlier case than a broader one ("martini rosso").
    case sweetVermouth, blancVermouth, dryVermouth
    case campari, aperol, benedictine, maraschino
    case orangeBitters, chocolateBitters, aromaticBitters, peychauds, absinthe
    case greenChartreuse, yellowChartreuse, coffeeLiqueur, drambuie
    case apricotLiqueur, peachLiqueur
    case cremeDeCassis, cremeDeViolette, cremeDeCacao, cremeDeMenthe, cremeDeMure, cremeDeFramboise
    case orangeLiqueur, amaretto, cynar, fernet, amaroNonino
    case lilletBlanc, lilletRouge, finoSherry, amontilladoSherry, port
    case sparklingWine, redWine, pimms, cherryHeering, allspiceDram, falernum

    /// Recognizes a bottle from its name in any of the app's languages, ignoring case and accents.
    /// Bare brands shared by several styles (such as "Martini" or "Lillet") resolve to `nil`.
    init?(name: String) {
        // Padded so a fragment can ask for a whole word (" porto ") or the end of the name (" port $").
        let folded = "^ " + name.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: nil) + " $"
        // Maraschino cherries are a garnish, not the liqueur.
        let isCherry = Self.cherryWords.contains { folded.contains($0) }
        guard let style = Self.allCases.first(where: { style in
            !(style == .maraschino && isCherry) && style.fragments.contains { folded.contains($0) }
        }) else { return nil }
        self = style
    }

    private static let cherryWords = ["cherr", "ciliegi", "cereza", "cerise", "kirsche"]

    /// Folded generic names (en, it, es, fr, de) and brands that identify the style.
    private var fragments: [String] {
        switch self {
        case .sweetVermouth: [
            "sweet vermouth", "sweet red vermouth", "red vermouth", "vermouth rosso", "vermouth rouge",
            "vermouth doux", "vermouth dolce", "vermouth dulce", "vermut rojo", "vermut dulce", "vermut rosso",
            "martini rosso", "noilly prat rouge", "noilly prat ambre", "carpano antica", "carpano classico",
            "antica formula", "punt e mes", "cocchi vermouth", "roter wermut", "susser wermut", "susser vermouth",
            "susser vermut", "wermut rot", "roter vermouth"
        ]
        case .blancVermouth: [
            "white vermouth", "blanc vermouth", "vermouth blanc", "vermouth bianco", "vermouth blanco",
            "vermut blanco", "vermut bianco", "martini bianco", "carpano bianco", "dolin blanc", "weisser wermut",
            "weisser vermouth", "weisser vermut", "wermut weiss"
        ]
        case .dryVermouth: [
            "dry vermouth", "vermouth dry", "extra dry vermouth", "martini extra dry", "martini dry", "noilly prat",
            "dolin dry", "carpano dry", "vermouth secco", "vermouth seco", "vermut seco", "vermut secco",
            "vermouth sec", "vermut sec", "trockener wermut", "trockener vermut", "wermut trocken",
            "vermouth trocken"
        ]
        case .campari: ["campari"]
        case .aperol: ["aperol"]
        case .benedictine: ["benedictine", "benedettino"]
        case .maraschino: [
            "maraschino liqueur", "luxardo maraschino", "maraschino luxardo", "liquore di maraschino",
            "licor de maraschino", "maraschinolikor", "maraschino likor", "maraschino-likor", "liquore maraschino",
            "licor de marrasquino", "liqueur de marasquin"
        ]
        case .orangeLiqueur: [
            "cointreau", "couintreau", "triple sec", "curacao", "grand marnier", "combier liqueur d'orange",
            "orange liqueur", "liquore all'arancia", "liquore d'arancia", "liquore di arancia", "licor de naranja",
            "liqueur d'orange", "liqueur d orange", "orangenlikor"
        ]
        case .orangeBitters: [
            "orange bitters", "bitter all'arancia", "bitter d'arancia", "amargo de naranja",
            "bitter a l'orange", "bitter d'orange", "orangenbitter"
        ]
        case .chocolateBitters: ["chocolate bitters", "mole bitters", "cacao bitters"]
        case .aromaticBitters: [
            "angostura", "aromatic bitters", "bitter aromatico", "amargo aromatico", "bitter aromatique",
            "aromatische bitter"
        ]
        case .peychauds: ["peychaud"]
        case .absinthe: ["absinth", "absenta", "assenzio", "herbsaint"]
        case .greenChartreuse: [
            "green chartreuse", "chartreuse verde", "chartreuse verte", "gruner chartreuse", "grune chartreuse",
            "chartreuse grun"
        ]
        case .yellowChartreuse: [
            "yellow chartreuse", "chartreuse gialla", "chartreuse giallo", "chartreuse amarilla",
            "chartreuse jaune", "gelber chartreuse", "gelbe chartreuse", "chartreuse gelb"
        ]
        case .coffeeLiqueur: [
            "kahlua", "coffee liqueur", "tia maria", "mr black", "liquore al caffe", "licor de cafe",
            "liqueur de cafe", "kaffeelikor", "espressolikor"
        ]
        case .drambuie: ["drambuie"]
        case .apricotLiqueur: [
            "apricot liqueur", "apricot brandy", "liquore all'albicocca", "liquore di albicocca",
            "licor de albaricoque", "licor de damasco", "liqueur d'abricot", "abricot brandy", "aprikosenlikor"
        ]
        case .peachLiqueur: [
            "peach liqueur", "peach schnapps", "peach brandy", "creme de peche", "liqueur de peche",
            "liquore alla pesca", "crema di pesca", "licor de melocoton", "crema de melocoton",
            "pfirsichlikor", "pfirsichschnaps", "schnaps di pesca"
        ]
        case .cremeDeCassis: [
            "creme de cassis", "crema di cassis", "crema de casis", "cassis liqueur", "liqueur de cassis",
            "liquore di cassis", "licor de casis", "cassislikor"
        ]
        case .cremeDeViolette: [
            "creme de violette", "creme de violet", "crema di violetta", "crema de violeta", "violet liqueur",
            "liqueur de violette", "liquore alla viola", "licor de violeta", "veilchenlikor", "creme yvette"
        ]
        case .cremeDeCacao: [
            "creme de cacao", "crema di cacao", "crema de cacao", "cacao liqueur", "liqueur de cacao",
            "kakaolikor", "chocolate liqueur"
        ]
        case .cremeDeMenthe: [
            "creme de menthe", "crema di menta", "crema de menta", "minzlikor", "pfefferminzlikor",
            "mint liqueur"
        ]
        case .cremeDeMure: [
            "creme de mure", "crema di more", "crema di mora", "crema de mora", "brombeerlikor",
            "blackberry liqueur"
        ]
        case .cremeDeFramboise: [
            "framboise", "raspberry liqueur", "chambord", "liquore al lampone", "licor de frambuesa",
            "himbeerlikor"
        ]
        case .amaretto: ["amaretto", "disaronno"]
        case .cynar: ["cynar"]
        case .fernet: ["fernet"]
        case .amaroNonino: ["amaro nonino", "nonino amaro", "nonino quintessentia"]
        case .lilletBlanc: ["lillet blanc", "lillet bianco", "lillet blanco", "lillet weiss"]
        case .lilletRouge: ["lillet rouge", "lillet rosso", "lillet rojo", "lillet rot"]
        case .finoSherry: [
            "fino sherry", "sherry fino", "jerez fino", "xeres fino", "fino jerez", "sherry-fino", "tio pepe",
            "manzanilla sherry", "sherry manzanilla", "jerez manzanilla", "manzanilla jerez"
        ]
        case .amontilladoSherry: ["amontillado"]
        case .port: [
            " port $", "port wine", "ruby port", "tawny port", "white port", "vintage port", " lbv ",
            "late bottled vintage", " porto ", "oporto", "portwein", "vin de porto"
        ]
        case .sparklingWine: [
            "champagne $", "champagne or ", "prosecco", "sparkling wine", "spumante", " cava ", " sekt ",
            "cremant", "vin mousseux", "vino espumoso", "franciacorta"
        ]
        case .redWine: [
            "red wine $", "vino rosso $", "vino tinto $", "vin rouge $", "rotwein $", "roter wein $",
            "pinot noir", "cabernet", "merlot"
        ]
        case .pimms: ["pimm"]
        case .cherryHeering: [
            "heering", "cherry liqueur", "cherry brandy", "kirschlikor", "licor de cereza", "liqueur de cerise",
            "liquore alla ciliegia"
        ]
        case .allspiceDram: ["allspice dram", "pimento dram", "elizabeth allspice"]
        case .falernum: ["falernum"]
        }
    }
}
