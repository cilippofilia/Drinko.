//
//  ContentFileTests.swift
//  DrinkoPro
//

import Testing
@testable import DrinkoPro

struct ContentFileTests {
    @Test func cocktailsPathIsNotLocalized() {
        #expect(ContentFile.cocktails.remotePath(language: "de") == "cocktails/cocktails.json")
    }

    @Test func cocktailFilesLiveUnderCocktails() {
        #expect(ContentFile.procedure.remotePath(language: "it") == "cocktails/procedure/it/procedure.json")
        #expect(ContentFile.shots.remotePath(language: "fr") == "cocktails/shots/fr/shots.json")
        #expect(ContentFile.history.remotePath(language: "es") == "cocktails/history/es/history.json")
    }

    @Test func learnFilesLiveAtRoot() {
        #expect(ContentFile.books.remotePath(language: "es") == "books/es/books.json")
        #expect(ContentFile.topic("bar-preps").remotePath(language: "fr") == "bar-preps/fr/bar-preps.json")
        #expect(ContentFile.topics.remotePath(language: "en") == "topics/en/topics.json")
    }

    @Test func cacheKeyMatchesRemotePath() {
        #expect(ContentFile.books.cacheKey(language: "de") == ContentFile.books.remotePath(language: "de"))
        #expect(ContentFile.books.bundleFileName == "books.json")
        #expect(ContentFile.fixedFiles.count == 6)
    }

    @Test func languageResolution() {
        #expect(ContentLanguage.resolve(["it"]) == "it")
        #expect(ContentLanguage.resolve(["pt-BR"]) == "en")
        #expect(ContentLanguage.resolve([]) == "en")
        #expect(ContentLanguage.resolve(["de-AT"]) == "de")
        #expect(ContentLanguage.resolve(["FR_ca"]) == "fr")
    }
}
