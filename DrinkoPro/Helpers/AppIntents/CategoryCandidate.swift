import Foundation

/// A Cabinet category reduced to plain values, so guessing never touches SwiftData.
struct CategoryCandidate: Sendable, Equatable {
    let id: UUID
    let name: String
    let color: String
}
