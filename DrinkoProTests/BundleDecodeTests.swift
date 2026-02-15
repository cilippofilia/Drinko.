import Testing
import Foundation
@testable import DrinkoPro

struct BundleDecodeTests {
    struct TestItem: Codable, Equatable {
        let id: String
        let name: String
    }

    private final class BundleMarker {}

    @Test func decodeLoadsTestItemsFromBundle() {
        let bundle = Bundle(for: BundleMarker.self)
        let items: [TestItem] = bundle.decode([TestItem].self, from: "TestItems.json")

        #expect(items.count == 2)
        #expect(items.first == TestItem(id: "one", name: "Test One"))
        #expect(items.last == TestItem(id: "two", name: "Test Two"))
    }
}
