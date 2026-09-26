//
//  BundleDecodableTests.swift
//  DrinkoProTests
//
//  Created by Filippo Cilia on 26/09/2026.
//

import XCTest
@testable import DrinkoPro

/// Verifies that every localized copy of the Learn JSON files bundled with the app decodes to a
/// non-empty array, guarding against `Bundle.decode` silently swallowing a decoding failure and
/// returning `[]` for a locale.
///
/// `DrinkoProTests` runs hosted by the `DrinkoPro` app (see the test target's `TEST_HOST` build
/// setting), so `Bundle.main` here resolves to the app's bundle and its real localized
/// resources — not the loose JSON copies also present in `DrinkoProTests/` for other tests.
final class BundleDecodableTests: XCTestCase {
    private let lessonResourceFiles = [
        "basic-lessons.json",
        "advanced-lessons.json",
        "bar-preps.json",
        "basic-spirits.json",
        "advanced-spirits.json",
        "liqueurs.json",
        "syrups.json"
    ]

    private var appLocalizations: [String] {
        Bundle.main.localizations.filter { $0 != "Base" }
    }

    func testEachLocalizedLessonFileDecodesNonEmpty() throws {
        let locales = appLocalizations
        XCTAssertFalse(locales.isEmpty, "Expected the app bundle to expose at least one localization.")

        for locale in locales {
            for resourceFile in lessonResourceFiles {
                guard let url = Bundle.main.url(
                    forResource: resourceFile,
                    withExtension: nil,
                    subdirectory: nil,
                    localization: locale
                ) else {
                    XCTFail("Missing \(resourceFile) for locale '\(locale)' in the app bundle.")
                    continue
                }

                let data = try Data(contentsOf: url)
                let lessons = try JSONDecoder().decode([Lesson].self, from: data)
                XCTAssertFalse(lessons.isEmpty, "\(resourceFile) (\(locale)) decoded to an empty array.")
            }
        }
    }

    func testEachLocalizedBooksFileDecodesNonEmpty() throws {
        let locales = appLocalizations
        XCTAssertFalse(locales.isEmpty, "Expected the app bundle to expose at least one localization.")

        for locale in locales {
            guard let url = Bundle.main.url(
                forResource: "books.json",
                withExtension: nil,
                subdirectory: nil,
                localization: locale
            ) else {
                XCTFail("Missing books.json for locale '\(locale)' in the app bundle.")
                continue
            }

            let data = try Data(contentsOf: url)
            let books = try JSONDecoder().decode([Book].self, from: data)
            XCTAssertFalse(books.isEmpty, "books.json (\(locale)) decoded to an empty array.")
        }
    }
}
