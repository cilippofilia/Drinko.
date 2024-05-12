//
//  CachedImageManager.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 12/05/2024.
//

import Foundation

class CachedImageManager: ObservableObject {
    // Published property to track the current state of image loading
    @Published private(set) var currentState: CurrentState?

    // Instance of ImageRetriever to fetch images
    private let imageRetriever = ImageRetriever()

    // Asynchronous function to load an image from a URL
    @MainActor
    func load(
        _ imageUrl: String,
        cache: ImageCache = .shared
    ) async {
        // Set the current state to loading
        self.currentState = .loading

        // Check if the image is available in cache
        if let imageData = cache.object(forKey: imageUrl as NSString) {
            // Update current state to success if image is found in cache
            self.currentState = .success(data: imageData)
            #if DEBUG
            print("📱 Fetching image from the cache: \(imageUrl)")
            #endif
            return
        }

        // If image is not found in cache, attempt to fetch it
        do {
            let data = try await imageRetriever.fetch(imageUrl)
            // Update current state to success and cache the image data
            self.currentState = .success(data: data)
            cache.set(
                object: data as NSData,
                forKey: imageUrl as NSString
            )
            #if DEBUG
            print("📱 Caching image: \(imageUrl)")
            #endif
        } catch {
            // Update current state to failed if image retrieval fails
            currentState = .failed(error: error)
        }
    }
}

// Extension to CachedImageManager defining states of image loading
extension CachedImageManager {
    public enum CurrentState {
        case loading
        case success(data: Data)
        case failed(error: Error)
    }
}

// Extension to make CachedImageManager.CurrentState equatable
extension CachedImageManager.CurrentState: Equatable {
    static func == (lhs: CachedImageManager.CurrentState, rhs: CachedImageManager.CurrentState) -> Bool {
        // Compare states for equality
        switch (lhs, rhs) {
        case (.loading, .loading):
            return true
        case (let .failed(lhsError), let .failed(rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        case (let .success(lhsData), let .success(rhsData)):
            return lhsData == rhsData
        default:
            return false
        }
    }
}
