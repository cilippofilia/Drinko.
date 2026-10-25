import Foundation
#if canImport(FoundationModels)
import FoundationModels
#endif

/// Asks the on-device model which Cabinet category a bottle belongs in, when the keyword
/// guess is unsure.
enum ModelCategoryGuesser {
    /// The category whose name equals `answer`, ignoring case and surrounding spaces. Anything
    /// else, including "unsure", is no match.
    static func candidate(forAnswer answer: String, among categories: [CategoryCandidate]) -> CategoryCandidate? {
        let cleaned = answer.trimmingCharacters(in: .whitespacesAndNewlines)
        let options: String.CompareOptions = [.caseInsensitive, .diacriticInsensitive]
        return categories.first { $0.name.compare(cleaned, options: options) == .orderedSame }
    }

    /// The model's pick, or `nil` when it is unsure or unavailable.
    static func guess(bottle: String, among categories: [CategoryCandidate]) async -> CategoryCandidate? {
        #if canImport(FoundationModels)
        if #available(iOS 26, macOS 26, *) {
            return await modelGuess(bottle: bottle, among: categories)
        }
        #endif
        return nil
    }
}

#if canImport(FoundationModels)
@available(iOS 26, macOS 26, *)
@Generable
private struct CategoryAnswer {
    @Guide(description: "Exactly one of the given category names, or the word unsure")
    let category: String
}

@available(iOS 26, macOS 26, *)
private extension ModelCategoryGuesser {
    static func modelGuess(bottle: String, among categories: [CategoryCandidate]) async -> CategoryCandidate? {
        guard SystemLanguageModel.default.availability == .available else { return nil }
        let names = categories.map(\.name).joined(separator: ", ")
        let session = LanguageModelSession(
            instructions: "You sort liquor bottles into the bar categories you are given."
        )
        let prompt = "Bottle: \(bottle)\nCategories: \(names)\nPick the category this bottle belongs in, or unsure."
        do {
            let response = try await session.respond(to: prompt, generating: CategoryAnswer.self)
            return candidate(forAnswer: response.content.category, among: categories)
        } catch {
            return nil
        }
    }
}
#endif
