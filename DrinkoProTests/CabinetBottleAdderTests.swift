import Foundation
import SwiftData
import Testing
@testable import DrinkoPro

@MainActor
@Suite("CabinetBottleAdder")
struct CabinetBottleAdderTests {
    /// The container must outlive the context, so both are returned.
    private func makeStore() throws -> (container: ModelContainer, context: ModelContext) {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Category.self, Item.self, configurations: configuration)
        return (container, container.mainContext)
    }

    @Test
    func addsOnceToACategoryWithNoProductsArray() throws {
        let (container, context) = try makeStore()
        defer { withExtendedLifetime(container) {} }
        let category = Category(name: "Gins", creationDate: Date())
        category.products = nil
        context.insert(category)

        let item = try CabinetBottleAdder.add("Tanqueray", to: category, in: context)

        #expect(category.products?.count == 1)
        #expect(item.category === category)
        #expect(try context.fetch(FetchDescriptor<Item>()).count == 1)
    }

    @Test
    func addsOnceToACategoryWithAProduct() throws {
        let (container, context) = try makeStore()
        defer { withExtendedLifetime(container) {} }
        let category = Category(name: "Gins", creationDate: Date())
        context.insert(category)
        try CabinetBottleAdder.add("Plymouth", to: category, in: context)

        let item = try CabinetBottleAdder.add("Tanqueray", to: category, in: context)

        #expect(category.products?.count == 2)
        #expect(item.category === category)
        #expect(try context.fetch(FetchDescriptor<Item>()).count == 2)
    }
}
