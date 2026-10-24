//
//  LearnTopicTests.swift
//  DrinkoProTests
//

import Foundation
import Testing
@testable import DrinkoPro

@MainActor
struct LearnTopicTests {
    @Test func bundledTopicsKeepTodaysOrderAndSymbols() {
        #expect(LearnTopic.bundled.map(\.id) == [
            "basic-lessons", "bar-preps", "basic-spirits", "advanced-spirits",
            "liqueurs", "advanced-lessons", "syrups"
        ])
        #expect(LearnTopic.bundled.map(\.symbol) == [
            "graduationcap", "list.bullet.clipboard", "waterbottle", "star",
            "drop.halffull", "brain.head.profile", "flask"
        ])
    }

    @Test func everyLanguageManifestHasSameIDs() throws {
        var idsByLanguage: [String: [String]] = [:]
        for language in ["en", "de", "es", "fr", "it"] {
            let url = try #require(
                Bundle.main.url(
                    forResource: "topics", withExtension: "json", subdirectory: nil, localization: language
                ),
                "Missing topics.json for \(language)"
            )
            let topics = try JSONDecoder().decode([LearnTopic].self, from: Data(contentsOf: url))
            #expect(topics.allSatisfy { !$0.title.isEmpty }, "Empty title in \(language)")
            idsByLanguage[language] = topics.map(\.id)
        }
        let english = idsByLanguage["en"]
        for (language, ids) in idsByLanguage {
            #expect(ids == english, "\(language) differs from en")
        }
    }

    @Test func unknownSymbolFallsBack() {
        let viewModel = LessonsViewModel(topics: [LearnTopic(id: "x", title: "X", symbol: "not.a.symbol")])
        #expect(viewModel.sidebarSymbol(for: "x") == "book")
    }
}
