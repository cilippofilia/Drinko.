//
//  UserCocktailPhotoSection.swift
//  DrinkoPro
//

import SwiftUI

/// The Photo section of the create/edit cocktail forms: a preview of the photo, a menu to
/// take or choose one, and a way to remove it. Edits a draft; the form saves it.
struct UserCocktailPhotoSection: View {
    @Binding var photoData: Data?

    /// Decoded once per photo, not on every keystroke elsewhere in the form.
    @State private var preview: CGImage?

    /// The preview's height in the form.
    @ScaledMetric private var previewHeight: CGFloat = 180

    var body: some View {
        Section("Photo") {
            if let preview {
                Image(preview, scale: 1, label: Text("Cocktail photo"))
                    .resizable()
                    .scaledToFill()
                    .frame(height: previewHeight)
                    .frame(maxWidth: .infinity)
                    .clipShape(.rect(cornerRadius: 12))
            }

            CocktailPhotoMenu(
                onPick: { photoData = $0 },
                label: {
                    Label(photoData == nil ? "Add Photo" : "Replace Photo", systemImage: "photo.badge.plus")
                }
            )
            // Decodes once per photo change, on this always-present row rather than the Section.
            .task(id: photoData) {
                preview = photoData.flatMap { UserPhotoProcessor.thumbnail(from: $0, maxPixelSize: 900) }
            }

            if photoData != nil {
                Button("Remove Photo", systemImage: "trash", role: .destructive) {
                    photoData = nil
                }
            }
        }
    }
}
