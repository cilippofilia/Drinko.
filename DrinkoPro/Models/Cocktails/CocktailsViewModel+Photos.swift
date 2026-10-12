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

    /// Whether the user has turned this cocktail's photo into a sticker.
    func hasSticker(_ cocktail: Cocktail) -> Bool {
        cocktailIDsWithStickers.contains(cocktail.id)
    }

    /// Whether there's a picture of the drink to show: bundled drinks always have a sticker or
    /// photo; the user's own cocktails only once they add one.
    func hasPicture(_ cocktail: Cocktail) -> Bool {
        !cocktail.isUserCreated || hasPhoto(cocktail) || hasSticker(cocktail)
    }

    /// The card color the user picked for this cocktail, whether or not a main spirit is
    /// currently overriding it. `nil` when they haven't picked one.
    func pickedTintColor(for cocktail: Cocktail) -> String? {
        userTintColors[cocktail.id]
    }

    /// How many times this cocktail's photo has changed this session.
    func photoRevision(for id: String) -> Int {
        photoRevisions[id, default: 0]
    }

    /// The stored photo, for prefilling the edit form.
    func photoData(for cocktail: Cocktail) -> Data? {
        userCreatedCocktails.first { $0.id == cocktail.id }?.photoData
    }

    /// The stored sticker, for prefilling the edit form.
    func stickerData(for cocktail: Cocktail) -> Data? {
        userCreatedCocktails.first { $0.id == cocktail.id }?.stickerData
    }

    /// Stores an already-processed photo for the cocktail, or removes it when `data` is nil.
    func setPhoto(_ data: Data?, for cocktail: Cocktail) {
        guard let existing = userCreatedCocktails.first(where: { $0.id == cocktail.id }) else { return }
        existing.photoData = data
        // The header's Add Photo has no sticker step, so an older sticker would be stale.
        existing.stickerData = nil
        existing.lastUpdated = Date()
        photoDidChange(for: existing.id)
        saveUserCocktails()
    }

    /// A decoded thumbnail of the cocktail's photo no larger than `maxPixelSize`, cached per
    /// revision and size so scrolling doesn't decode the JPEG again.
    func photoThumbnail(for id: String, revision: Int, maxPixelSize: Int) -> CGImage? {
        // Photos are stored at most this big, so larger requests can share one entry.
        let maxPixelSize = min(maxPixelSize, UserPhotoProcessor.maxStoredPixelSize)
        return cachedThumbnail(id: id, key: "\(id)#\(revision)#\(maxPixelSize)", maxPixelSize: maxPixelSize) {
            $0.photoData
        }
    }

    /// A decoded thumbnail of the cocktail's sticker no larger than `maxPixelSize`, cached like
    /// photo thumbnails but under its own keys.
    func stickerThumbnail(for id: String, revision: Int, maxPixelSize: Int) -> CGImage? {
        let maxPixelSize = min(maxPixelSize, Int(StickerMaker.maxLongSide))
        return cachedThumbnail(
            id: id, key: "sticker#\(id)#\(revision)#\(maxPixelSize)", maxPixelSize: maxPixelSize
        ) {
            $0.stickerData
        }
    }

    /// Looks `key` up in the thumbnail cache, or decodes the image `data` picks out of the
    /// cocktail with `id` and caches it.
    private func cachedThumbnail(
        id: String,
        key: String,
        maxPixelSize: Int,
        data: (UserCreatedCocktail) -> Data?
    ) -> CGImage? {
        let cacheKey = key as NSString
        if let cached = photoThumbnailCache.object(forKey: cacheKey) {
            return cached
        }
        guard let stored = userCreatedCocktails.first(where: { $0.id == id }).flatMap(data),
              let image = UserPhotoProcessor.thumbnail(from: stored, maxPixelSize: maxPixelSize) else {
            return nil
        }
        photoThumbnailCache.setObject(image, forKey: cacheKey, cost: image.bytesPerRow * image.height)
        return image
    }

    /// Moves the cocktail to a new photo revision. Thumbnails cached for older revisions are never
    /// asked for again and age out of the cache.
    func photoDidChange(for id: String) {
        photoRevisions[id, default: 0] += 1
    }
}
