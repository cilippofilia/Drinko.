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
        ("peach schnapps", .peachLiqueur), ("Disaronno", .amaretto), ("prosecco", .sparklingWine)
    ])
    func resolves(_ name: String, _ style: BottleStyle) { #expect(BottleStyle(name: name) == style) }

    @Test(arguments: ["Martini", "Absolut", "lime juice", "London dry gin"])
    func doesNotResolve(_ name: String) { #expect(BottleStyle(name: name) == nil) }
}
