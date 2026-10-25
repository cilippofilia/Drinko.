import AppIntents
import Foundation
import SwiftData

/// A Cabinet category exposed to Siri and Shortcuts, built from the `Category` model.
/// Its members are `nonisolated` one by one: marking the whole type would also mark the
/// `@Property` storage, which Swift 6 rejects.
struct CabinetCategoryEntity: AppEntity {
    nonisolated static let typeDisplayRepresentation: TypeDisplayRepresentation = "Category"
    nonisolated static let defaultQuery = CabinetCategoryEntityQuery()

    nonisolated let id: UUID

    @Property(title: "Name")
    var name: String

    nonisolated init(id: UUID, name: String) {
        self.id = id
        self.name = name
    }

    nonisolated var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)")
    }
}

/// Lists the user's categories from the app's own store.
struct CabinetCategoryEntityQuery: EnumerableEntityQuery {
    @Dependency private var modelContainer: ModelContainer

    @MainActor
    func allEntities() async throws -> [CabinetCategoryEntity] {
        let categories = (try? modelContainer.mainContext.fetch(FetchDescriptor<Category>())) ?? []
        return categories
            .sorted { $0.creationDate < $1.creationDate }
            .map { CabinetCategoryEntity(id: $0.id, name: $0.name) }
    }

    @MainActor
    func entities(for identifiers: [UUID]) async throws -> [CabinetCategoryEntity] {
        try await allEntities().filter { identifiers.contains($0.id) }
    }
}
