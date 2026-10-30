import Testing
@testable import DrinkoPro

@Suite("BottleStyle") struct BottleStyleTests {
    @Test(arguments: [
        ("sweet red vermouth", BottleStyle.sweetVermouth), ("Carpano Antica Formula", .sweetVermouth),
        ("Vermouth Rosso", .sweetVermouth), ("dry vermouth", .dryVermouth), ("Noilly Prat", .dryVermouth),
        ("Vermouth secco", .dryVermouth), ("Vermut seco", .dryVermouth), ("trockener Wermut", .dryVermouth),
        ("Martini Extra Dry", .dryVermouth), ("Martini Rosso", .sweetVermouth),
        ("green chartreuse", .greenChartreuse), ("Chartreuse verde", .greenChartreuse),
        ("yellow chartreuse", .yellowChartreuse), ("Kahlúa", .coffeeLiqueur), ("Luxardo Maraschino", .maraschino),
        ("Cointreau", .orangeLiqueur), ("couintreau", .orangeLiqueur), ("Angostura", .aromaticBitters),
        ("peach schnapps", .peachLiqueur), ("Disaronno", .amaretto), ("prosecco", .sparklingWine),
        ("Angostura Orange Bitters", .orangeBitters), ("Noilly Prat Rouge", .sweetVermouth),
        ("Carpano Bianco", .blancVermouth), ("Carpano Dry", .dryVermouth), ("Combier Creme de Peche", .peachLiqueur),
        ("Combier Liqueur d'Orange", .orangeLiqueur), ("Süßer Wermut", .sweetVermouth),
        ("Weißer Wermut", .blancVermouth), ("maraschino liqueur", .maraschino),
        ("Liqueur d’orange", .orangeLiqueur), ("Liquore all’arancia", .orangeLiqueur),
        ("creme de cassis", .cremeDeCassis), ("dark creme de cacao", .cremeDeCacao),
        ("creme de violette", .cremeDeViolette), ("champagne", .sparklingWine), ("port", .port),
        ("Taylor's Port", .port), ("Sandeman Founders Reserve Port", .port),
        ("Late Bottled Vintage", .port),
        ("pinot noir or similar", .redWine), ("amaro nonino", .amaroNonino)
    ])
    func resolves(_ name: String, _ style: BottleStyle) { #expect(BottleStyle(name: name) == style) }

    @Test(arguments: ["Martini", "Absolut", "lime juice", "London dry gin", "maraschino cherry",
                         "Luxardo Maraschino Cherries", "Maraschino Luxardo Cherries", "violet syrup",
                         "cacao nibs", "cassis syrup", "Port Ellen", "manzanilla olives", "Nonino grappa",
                         "red wine vinegar", "champagne vinegar", "cavalry"])
    func doesNotResolve(_ name: String) { #expect(BottleStyle(name: name) == nil) }
}
