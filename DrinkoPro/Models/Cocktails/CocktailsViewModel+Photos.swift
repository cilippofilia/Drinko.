//
//  CocktailsViewModel+Photos.swift
//  DrinkoPro
//

import CoreGraphics
import Foundation

extension CocktailsViewModel {
    /// Whether the user has added a photo to this cocktail.
    func hasPhoto(_ cocktail: Cocktail) -> Bool {
        cocktailIDsWithPhotos.contains(cocktail.id)
    }

    /// Whether there's a picture of the drink to show: bundled drinks always have a sticker or
    /// photo; the user's own cocktails only once they add one.
    func hasPicture(_ cocktail: Cocktail) -> Bool {
        !cocktail.isUserCreated || hasPhoto(cocktail)
    }

    /// How many times this cocktail's photo has changed this session.
    func photoRevision(for id: String) -> Int {
        photoRevisions[id, default: 0]
    }

    /// The stored photo, for prefilling the edit form.
    func photoData(for cocktail: Cocktail) -> Data? {
        userCreatedCocktails.first { $0.id == cocktail.id }?.photoData
    }

    /// Stores an already-processed photo for the cocktail, or removes it when `data` is nil.
    func setPhoto(_ data: Data?, for cocktail: Cocktail) {
        guard let existing = userCreatedCocktails.first(where: { $0.id == cocktail.id }) else { return }
        existing.photoData = data
        existing.lastUpdated = Date()
        photoDidChange(for: existing.id)
        saveUserCocktails()
    }

    /// A decoded thumbnail of the cocktail's photo no larger than `maxPixelSize`, cached per
    /// revision and size so scrolling doesn't decode the JPEG again.
    func photoThumbnail(for id: String, revision: Int, maxPixelSize: Int) -> CGImage? {
        // Photos are stored at most this big, so larger requests can share one entry.
        let maxPixelSize = min(maxPixelSize, UserPhotoProcessor.maxStoredPixelSize)
        let key = "\(id)#\(revision)#\(maxPixelSize)" as NSString
        if let cached = photoThumbnailCache.object(forKey: key) {
            return cached
        }
        guard let data = userCreatedCocktails.first(where: { $0.id == id })?.photoData,
              let image = UserPhotoProcessor.thumbnail(from: data, maxPixelSize: maxPixelSize) else {
            return nil
        }
        photoThumbnailCache.setObject(image, forKey: key, cost: image.bytesPerRow * image.height)
        return image
    }

    /// Moves the cocktail to a new photo revision. Thumbnails cached for older revisions are never
    /// asked for again and age out of the cache.
    func photoDidChange(for id: String) {
        photoRevisions[id, default: 0] += 1
    }
}
