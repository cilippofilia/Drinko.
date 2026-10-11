import CoreGraphics
import Foundation
import ImageIO
import SwiftData
import Testing
import UniformTypeIdentifiers
@testable import DrinkoPro

@MainActor
@Suite("User cocktail photos")
struct UserCocktailPhotoTests {
    private func makeViewModel() throws -> (CocktailsViewModel, ModelContainer) {
        let container = try ModelContainer(
            for: UserCreatedCocktail.self, UserIngredient.self, UserProcedure.self, UserProcedureStep.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true, cloudKitDatabase: .none)
        )
        let viewModel = CocktailsViewModel()
        viewModel.configure(modelContext: container.mainContext)
        return (viewModel, container)
    }

    private func details(photo: UserCocktailDetails.PhotoChange = .unchanged) -> UserCocktailDetails {
        UserCocktailDetails(
            name: "House Special", method: "stir", glass: "coupe", garnish: "", ice: "none", extra: "",
            ingredients: [Ingredient(name: "Gin", quantity: 2, unit: "oz.")],
            procedureSteps: [], photoChange: photo
        )
    }

    private func samplePhoto(width: Int = 400, height: Int = 300) throws -> Data {
        let context = try #require(CGContext(
            data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 0,
            space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue
        ))
        context.setFillColor(CGColor(red: 0.2, green: 0.4, blue: 0.9, alpha: 1))
        context.fill(CGRect(x: 0, y: 0, width: width, height: height))
        let image = try #require(context.makeImage())
        let data = NSMutableData()
        let destination = try #require(
            CGImageDestinationCreateWithData(data, UTType.jpeg.identifier as CFString, 1, nil)
        )
        CGImageDestinationAddImage(destination, image, nil)
        _ = CGImageDestinationFinalize(destination)
        return data as Data
    }

    @Test func addingWithAPhotoStoresIt() throws {
        let (viewModel, container) = try makeViewModel()
        _ = container
        viewModel.addUserCocktail(details(photo: .set(try samplePhoto())))
        let cocktail = try #require(viewModel.userCocktails.first)

        #expect(viewModel.hasPhoto(cocktail))
        #expect(viewModel.hasPicture(cocktail))
        #expect(viewModel.photoData(for: cocktail) != nil)
    }

    @Test func setPhotoShowsItEverywhere() throws {
        let (viewModel, container) = try makeViewModel()
        _ = container
        viewModel.addUserCocktail(details())
        let cocktail = try #require(viewModel.userCocktails.first)
        #expect(!viewModel.hasPicture(cocktail))
        #expect(viewModel.recentCocktailsWithPictures(from: [cocktail.id]).isEmpty)

        viewModel.setPhoto(try samplePhoto(), for: cocktail)

        #expect(viewModel.hasPicture(cocktail))
        #expect(viewModel.cardModel(for: cocktail).image == .userPhoto(id: cocktail.id, revision: 1))
        #expect(viewModel.recentCocktailsWithPictures(from: [cocktail.id]).map(\.id) == [cocktail.id])
        #expect(viewModel.photoThumbnail(for: cocktail.id, revision: 1, maxPixelSize: 100) != nil)
    }

    @Test func replacingAPhotoBumpsRevisionAndClearsThumbnails() throws {
        let (viewModel, container) = try makeViewModel()
        _ = container
        viewModel.addUserCocktail(details(photo: .set(try samplePhoto())))
        let cocktail = try #require(viewModel.userCocktails.first)
        let before = viewModel.photoRevision(for: cocktail.id)
        _ = viewModel.photoThumbnail(for: cocktail.id, revision: before, maxPixelSize: 100)
        #expect(!viewModel.photoThumbnailCache.isEmpty)

        viewModel.setPhoto(try samplePhoto(width: 200, height: 200), for: cocktail)

        #expect(viewModel.photoRevision(for: cocktail.id) == before + 1)
        #expect(viewModel.photoThumbnailCache.isEmpty)
    }

    @Test func removingAPhotoRestoresGlassArtwork() throws {
        let (viewModel, container) = try makeViewModel()
        _ = container
        viewModel.addUserCocktail(details(photo: .set(try samplePhoto())))
        let cocktail = try #require(viewModel.userCocktails.first)

        viewModel.updateUserCocktail(cocktail, with: details(photo: .remove))

        let updated = try #require(viewModel.userCocktails.first)
        #expect(!viewModel.hasPhoto(updated))
        #expect(viewModel.cardModel(for: updated).image == updated.glassArtwork)
        #expect(viewModel.recentCocktailsWithPictures(from: [updated.id]).isEmpty)
    }

    @Test func updatingWithUnchangedPhotoKeepsIt() throws {
        let (viewModel, container) = try makeViewModel()
        _ = container
        let photo = try samplePhoto()
        viewModel.addUserCocktail(details(photo: .set(photo)))
        let cocktail = try #require(viewModel.userCocktails.first)

        viewModel.updateUserCocktail(cocktail, with: details())

        let updated = try #require(viewModel.userCocktails.first)
        #expect(viewModel.photoData(for: updated) == photo)
        #expect(viewModel.photoRevision(for: updated.id) == viewModel.photoRevision(for: cocktail.id))
    }

    @Test func bundledCocktailsAlwaysHavePictures() throws {
        let viewModel = CocktailsViewModel()
        let bundled = try #require(viewModel.listOfCocktails.first)
        #expect(viewModel.hasPicture(bundled))
        #expect(!viewModel.hasPhoto(bundled))
    }
}
