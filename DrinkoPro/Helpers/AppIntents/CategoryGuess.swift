import Foundation

/// What the keyword rules concluded about a bottle's category.
enum CategoryGuess: Equatable {
    /// Exactly one category fits.
    case match(CategoryCandidate)
    /// Several categories fit, so the choice is only among these.
    case ambiguous([CategoryCandidate])
    /// Nothing fits, or the bottle isn't recognised.
    case unknown
}
