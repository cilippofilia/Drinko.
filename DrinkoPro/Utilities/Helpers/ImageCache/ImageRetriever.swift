//
//  ImageRetriever.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 12/05/2024.
//

import Foundation

struct ImageRetriever {
    func fetch(_ imageUrl: String) async throws -> Data {
        guard let url = URL(string: imageUrl) else {
            throw RetrieverError.invalidUrl
        }

        let (data, _) = try await URLSession.shared.data(from: url)
        return data
    }
}

private extension ImageRetriever {
    enum RetrieverError: Error {
        case invalidUrl
    }
}
