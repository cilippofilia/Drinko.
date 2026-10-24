//
//  ContentDecoding.swift
//  DrinkoPro
//

import Foundation

/// Why a content file was rejected.
enum ContentDecodingError: Error, Equatable {
    /// The file decoded to an empty array.
    case empty
    /// A topic id is not a lowercase, hyphen-separated slug, is used twice, or is the name of a fixed file.
    case invalidTopicID(String)
    /// A topic has no title.
    case emptyTopicTitle(String)
}

/// The single definition of what counts as valid content, shared by loading and downloading.
enum ContentDecoding {
    /// Throws unless `data` decodes into the file's model type, is non-empty and, for the topic
    /// manifest, only contains unique, path-safe ids and non-empty titles.
    static func validate(_ data: Data, as file: ContentFile) throws {
        _ = try decode(data, as: file)
    }

    /// Decodes `data` as an array of `T`, rejecting an empty array.
    static func decodeNonEmpty<T: Decodable>(_ type: T.Type, from data: Data) throws -> [T] {
        let values = try JSONDecoder().decode([T].self, from: data)
        guard !values.isEmpty else { throw ContentDecodingError.empty }
        return values
    }

    /// Decodes and validates the topic manifest. Ids become file paths, so they must stay inside the cache.
    static func decodeTopics(from data: Data) throws -> [LearnTopic] {
        let topics = try decodeNonEmpty(LearnTopic.self, from: data)
        var seen = Set<String>()
        let reserved = Set(ContentFile.fixedFiles.map(\.name))
        for topic in topics {
            guard topic.id.wholeMatch(of: /[a-z0-9]+(-[a-z0-9]+)*/) != nil,
                  !reserved.contains(topic.id),
                  seen.insert(topic.id).inserted else {
                throw ContentDecodingError.invalidTopicID(topic.id)
            }
            guard !topic.title.isEmpty else { throw ContentDecodingError.emptyTopicTitle(topic.id) }
        }
        return topics
    }

    private static func decode(_ data: Data, as file: ContentFile) throws -> Any {
        switch file.kind {
        case .cocktails, .shots:
            try decodeNonEmpty(Cocktail.self, from: data)
        case .history:
            try decodeNonEmpty(History.self, from: data)
        case .procedure:
            try decodeNonEmpty(Procedure.self, from: data)
        case .books:
            try decodeNonEmpty(Book.self, from: data)
        case .topics:
            try decodeTopics(from: data)
        case .lessons:
            try decodeNonEmpty(Lesson.self, from: data)
        }
    }
}
