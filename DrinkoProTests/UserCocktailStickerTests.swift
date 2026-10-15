import CoreGraphics
import CoreImage
import Foundation
import ImageIO
import SwiftData
import Testing
import UniformTypeIdentifiers
@testable import DrinkoPro

@MainActor
@Suite("User cocktail stickers")
struct UserCocktailStickerTests {
    private func makeViewModel() throws -> (CocktailsViewModel, ModelContainer) {
        let container = try ModelContainer(
            for: UserCreatedCocktail.self, UserIngredient.self, UserProcedure.self, UserProcedureStep.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true, cloudKitDatabase: .none)
        )
        let viewModel = CocktailsViewModel()
        viewModel.configure(modelContext: container.mainContext)
        return (viewModel, container)
    }

    private func details(
        photo: UserCocktailDetails.PhotoChange = .unchanged,
        sticker: UserCocktailDetails.PhotoChange = .unchanged
    ) -> UserCocktailDetails {
        UserCocktailDetails(
            name: "House Special", method: "stir", glass: "coupe", garnish: "", ice: "none", extra: "",
            ingredients: [Ingredient(name: "Gin", quantity: 2, unit: "oz.")],
            procedureSteps: [], photoChange: photo, stickerChange: sticker
        )
    }

    private func samplePhoto() throws -> Data {
        let context = try #require(CGContext(
            data: nil, width: 400, height: 300, bitsPerComponent: 8, bytesPerRow: 0,
            space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue
        ))
        context.setFillColor(CGColor(red: 0.2, green: 0.4, blue: 0.9, alpha: 1))
        context.fill(CGRect(x: 0, y: 0, width: 400, height: 300))
        let data = NSMutableData()
        let destination = try #require(
            CGImageDestinationCreateWithData(data, UTType.jpeg.identifier as CFString, 1, nil)
        )
        CGImageDestinationAddImage(destination, try #require(context.makeImage()), nil)
        _ = CGImageDestinationFinalize(destination)
        return data as Data
    }

    /// A real sticker PNG, made by the Core Image stage from a synthetic mask.
    private func sampleSticker() throws -> Data {
        let frame = CGRect(x: 0, y: 0, width: 200, height: 300)
        let subject = CGRect(x: 50, y: 60, width: 100, height: 180)
        let photo = CIImage(color: CIColor(red: 1, green: 0, blue: 0)).cropped(to: frame)
        let mask = CIImage(color: CIColor(red: 1, green: 1, blue: 1)).cropped(to: subject)
            .composited(over: CIImage(color: CIColor(red: 0, green: 0, blue: 0)).cropped(to: frame))
        return try StickerMaker.pngData(from: StickerMaker.composite(photo: photo, mask: mask))
    }

    @Test func changeBetweenDrafts() {
        let first = Data([1]), second = Data([2])
        #expect(UserCocktailDetails.PhotoChange.between(nil, nil) == .unchanged)
        #expect(UserCocktailDetails.PhotoChange.between(first, first) == .unchanged)
        #expect(UserCocktailDetails.PhotoChange.between(first, second) == .set(second))
        #expect(UserCocktailDetails.PhotoChange.between(nil, second) == .set(second))
        #expect(UserCocktailDetails.PhotoChange.between(first, nil) == .remove)
    }

    @Test func addingWithAStickerStoresAndShowsIt() throws {
        let (viewModel, container) = try makeViewModel()
        _ = container
        viewModel.addUserCocktail(details(photo: .set(try samplePhoto()), sticker: .set(try sampleSticker())))
        let cocktail = try #require(viewModel.userCocktails.first)

        #expect(viewModel.hasSticker(cocktail))
        #expect(viewModel.hasPicture(cocktail))
        #expect(viewModel.stickerData(for: cocktail) != nil)
        #expect(viewModel.photoData(for: cocktail) != nil)
    }

    @Test func aStickerWithoutAPhotoIsNotStored() throws {
        let (viewModel, container) = try makeViewModel()
        _ = container
        viewModel.addUserCocktail(details(sticker: .set(try sampleSticker())))
        let cocktail = try #require(viewModel.userCocktails.first)
        #expect(!viewModel.hasSticker(cocktail))
    }

    @Test func removingThePhotoRemovesTheSticker() throws {
        let (viewModel, container) = try makeViewModel()
        _ = container
        viewModel.addUserCocktail(details(photo: .set(try samplePhoto()), sticker: .set(try sampleSticker())))
        let cocktail = try #require(viewModel.userCocktails.first)

        viewModel.updateUserCocktail(cocktail, with: details(photo: .remove))

        #expect(!viewModel.hasSticker(cocktail))
        #expect(viewModel.stickerData(for: cocktail) == nil)
    }

    @Test func replacingThePhotoWithoutANewStickerDropsTheOldOne() throws {
        let (viewModel, container) = try makeViewModel()
        _ = container
        viewModel.addUserCocktail(details(photo: .set(try samplePhoto()), sticker: .set(try sampleSticker())))
        let cocktail = try #require(viewModel.userCocktails.first)

        viewModel.updateUserCocktail(cocktail, with: details(photo: .set(try samplePhoto())))

        #expect(viewModel.hasPhoto(cocktail))
        #expect(!viewModel.hasSticker(cocktail))
    }

    @Test func anOrphanStickerWithNoPhotoIsClearedOnSave() throws {
        let (viewModel, container) = try makeViewModel()
        _ = container
        viewModel.addUserCocktail(details(photo: .set(try samplePhoto()), sticker: .set(try sampleSticker())))
        let cocktail = try #require(viewModel.userCocktails.first)
        // Simulate a synced record that has a sticker but no photo.
        let stored = try #require(viewModel.userCreatedCocktails.first(where: { $0.id == cocktail.id }))
        stored.photoData = nil
        stored.stickerData = try sampleSticker()

        viewModel.updateUserCocktail(cocktail, with: details())

        #expect(!viewModel.hasSticker(cocktail))
    }

    @Test func addingAStickerToAPhotoOnlyCocktail() throws {
        let (viewModel, container) = try makeViewModel()
        _ = container
        viewModel.addUserCocktail(details(photo: .set(try samplePhoto())))
        let cocktail = try #require(viewModel.userCocktails.first)

        viewModel.updateUserCocktail(cocktail, with: details(sticker: .set(try sampleSticker())))

        #expect(viewModel.hasSticker(cocktail))
        #expect(viewModel.hasPhoto(cocktail))
        #expect(viewModel.cardModel(for: cocktail).image == .userSticker(
            id: cocktail.id, revision: viewModel.photoRevision(for: cocktail.id),
            tint: viewModel.stickerTint(for: cocktail)
        ))
    }

    @Test func turningTheStickerOffKeepsThePhoto() throws {
        let (viewModel, container) = try makeViewModel()
        _ = container
        viewModel.addUserCocktail(details(photo: .set(try samplePhoto()), sticker: .set(try sampleSticker())))
        let cocktail = try #require(viewModel.userCocktails.first)
        let before = viewModel.photoRevision(for: cocktail.id)

        viewModel.updateUserCocktail(cocktail, with: details(sticker: .remove))

        #expect(viewModel.hasPhoto(cocktail))
        #expect(!viewModel.hasSticker(cocktail))
        #expect(viewModel.photoRevision(for: cocktail.id) > before)
    }

    @Test func settingAPhotoFromTheHeaderDropsTheSticker() throws {
        let (viewModel, container) = try makeViewModel()
        _ = container
        viewModel.addUserCocktail(details(photo: .set(try samplePhoto()), sticker: .set(try sampleSticker())))
        let cocktail = try #require(viewModel.userCocktails.first)

        viewModel.setPhoto(try samplePhoto(), for: cocktail)

        #expect(!viewModel.hasSticker(cocktail))
    }

    @Test func stickerAndPhotoThumbnailsDontShareCacheEntries() throws {
        let (viewModel, container) = try makeViewModel()
        _ = container
        viewModel.addUserCocktail(details(photo: .set(try samplePhoto()), sticker: .set(try sampleSticker())))
        let cocktail = try #require(viewModel.userCocktails.first)
        let revision = viewModel.photoRevision(for: cocktail.id)

        let photo = try #require(viewModel.photoThumbnail(for: cocktail.id, revision: revision, maxPixelSize: 200))
        let sticker = try #require(viewModel.stickerThumbnail(for: cocktail.id, revision: revision, maxPixelSize: 200))

        // The photo is 4:3 and opaque; the sticker is tall and transparent at the corner.
        #expect(photo.width > photo.height)
        #expect(sticker.height > sticker.width)
        #expect(sticker.alphaInfo != .none && sticker.alphaInfo != .noneSkipLast)
    }

    @Test func libraryShowsTheStickerOverThePhoto() throws {
        let (viewModel, container) = try makeViewModel()
        _ = container
        viewModel.addUserCocktail(details(photo: .set(try samplePhoto()), sticker: .set(try sampleSticker())))
        let cocktail = try #require(viewModel.userCocktails.first)
        let revision = viewModel.photoRevision(for: cocktail.id)

        #expect(viewModel.cardModel(for: cocktail).image == .userSticker(
            id: cocktail.id, revision: revision, tint: viewModel.stickerTint(for: cocktail)
        ))

        viewModel.updateUserCocktail(cocktail, with: details(sticker: .remove))
        #expect(viewModel.cardModel(for: cocktail).image == .userPhoto(
            id: cocktail.id, revision: viewModel.photoRevision(for: cocktail.id)
        ))
    }

    @Test func tintedUserStickersTakeTheirTintAsHeroBackdrop() {
        #expect(RecentsHeroLayout.backdrop(for: .userSticker(id: "x", revision: 0, tint: "gin")) == .color("gin"))
        #expect(RecentsHeroLayout.backdrop(for: .userSticker(id: "x", revision: 0, tint: nil)) == .neutral)
    }
}
