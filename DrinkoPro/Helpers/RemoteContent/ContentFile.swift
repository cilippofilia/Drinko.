//
//  ContentFile.swift
//  DrinkoPro
//

import Foundation

/// A JSON content file that is bundled with the app and mirrored in the remote repository.
nonisolated struct ContentFile: Hashable, Sendable {
    /// What a file contains, which decides how it is decoded and where it lives. Part of the
    /// identity, so a topic whose id equals a fixed file's name is never equal to that file.
    enum Kind: Sendable {
        case cocktails, shots, history, procedure, books, topics, lessons
    }

    let kind: Kind
    /// The file name without extension, which is also its folder name in the remote repository.
    let name: String

    /// Whether the file has one copy per language.
    var isLocalized: Bool {
        switch kind {
        case .cocktails: false
        case .shots, .history, .procedure, .books, .topics, .lessons: true
        }
    }

    static let cocktails = ContentFile(kind: .cocktails, name: "cocktails")
    static let shots = ContentFile(kind: .shots, name: "shots")
    static let history = ContentFile(kind: .history, name: "history")
    static let procedure = ContentFile(kind: .procedure, name: "procedure")
    static let books = ContentFile(kind: .books, name: "books")
    static let topics = ContentFile(kind: .topics, name: "topics")

    /// Every file that is always fetched, as opposed to the per-topic files listed in `topics`.
    static let fixedFiles: [ContentFile] = [.cocktails, .shots, .history, .procedure, .books, .topics]

    /// The file for a single Learn topic.
    static func topic(_ id: String) -> ContentFile {
        ContentFile(kind: .lessons, name: id)
    }

    /// The name of the copy inside the app bundle.
    var bundleFileName: String { "\(name).json" }

    /// The path relative to the repository root. The cocktail files live under `cocktails/`.
    func remotePath(language: String) -> String {
        switch kind {
        case .cocktails:
            "\(name)/\(bundleFileName)"
        case .shots, .history, .procedure:
            "cocktails/\(name)/\(language)/\(bundleFileName)"
        case .books, .topics, .lessons:
            "\(name)/\(language)/\(bundleFileName)"
        }
    }

    /// The key used for ETags, equal to the remote path so each path is tracked separately.
    func cacheKey(language: String) -> String {
        remotePath(language: language)
    }
}
