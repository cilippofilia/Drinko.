//
//  UserCocktailPhotoSection.swift
//  DrinkoPro
//

import SwiftUI

/// The Photo section of the create/edit cocktail forms: a preview of the photo, a menu to
/// take or choose one, a way to remove it, and a toggle that turns it into a sticker.
/// Edits drafts; the form saves them.
struct UserCocktailPhotoSection: View {
    @Binding var photoData: Data?
    /// The sticker made from `photoData`, or nil when the toggle is off or it isn't made yet.
    @Binding var stickerData: Data?

    /// Decoded once per photo, not on every keystroke elsewhere in the form.
    @State private var preview: CGImage?
    @State private var stickerPreview: CGImage?
    @State private var makesSticker: Bool
    /// Owned by the form, which won't save while a sticker is still being made.
    @Binding var isMakingSticker: Bool
    @State private var stickerError: LocalizedStringResource?
    @State private var confirmsRemovingPhoto = false

    /// The preview's height in the form.
    @ScaledMetric private var previewHeight: CGFloat = 180

    init(photoData: Binding<Data?>, stickerData: Binding<Data?>, isMakingSticker: Binding<Bool>) {
        _photoData = photoData
        _stickerData = stickerData
        _isMakingSticker = isMakingSticker
        _makesSticker = State(initialValue: stickerData.wrappedValue != nil)
    }

    /// What the sticker task depends on: a new photo or flipping the toggle restarts it.
    private struct StickerJob: Equatable {
        let photo: Data?
        let isOn: Bool
    }

    var body: some View {
        Section {
            if makesSticker, let stickerPreview {
                Image(stickerPreview, scale: 1, label: Text("Cocktail sticker"))
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(StickerImageView.insetScale)
                    .frame(height: previewHeight)
                    .frame(maxWidth: .infinity)
                    .background { TintWash(tint: nil) }
                    .clipShape(.rect(cornerRadius: 12))
            } else if let preview {
                Image(preview, scale: 1, label: Text("Cocktail photo"))
                    .resizable()
                    .scaledToFill()
                    .frame(height: previewHeight)
                    .frame(maxWidth: .infinity)
                    .clipShape(.rect(cornerRadius: 12))
                    .overlay {
                        if isMakingSticker {
                            ProgressView()
                                .padding()
                                .background(.regularMaterial, in: .rect(cornerRadius: 12))
                        }
                    }
            }

            CocktailPhotoMenu(
                onPick: { newPhoto in
                    // A sticker belongs to the photo it was cut from.
                    photoData = newPhoto
                    stickerData = nil
                    stickerError = nil
                },
                label: {
                    Label(photoData == nil ? "Add Photo" : "Replace Photo", systemImage: "photo.badge.plus")
                        .labelStyle(.formAction)
                }
            )
            // A menu tints its whole label, so tint it with the text color; the label style
            // colors the icon itself.
            .tint(Color.primary)
            // Decodes once per photo change, on this always-present row rather than the Section.
            .task(id: photoData) {
                preview = photoData.flatMap { UserPhotoProcessor.thumbnail(from: $0, maxPixelSize: 900) }
            }

            if photoData != nil {
                Toggle("Make Sticker", systemImage: "wand.and.sparkles", isOn: $makesSticker)
                    .task(id: StickerJob(photo: photoData, isOn: makesSticker)) {
                        await updateSticker()
                    }
                    .task(id: stickerData) {
                        stickerPreview = stickerData.flatMap {
                            UserPhotoProcessor.thumbnail(from: $0, maxPixelSize: 900)
                        }
                    }

                Button(role: .destructive) {
                    confirmsRemovingPhoto = true
                } label: {
                    Label {
                        Text("Remove Photo")
                    } icon: {
                        // In a form the destructive role only reddens the title, and the icon
                        // keeps the app's tint, so color it explicitly.
                        Image(systemName: "trash")
                            .foregroundStyle(Color.red)
                    }
                }
                .confirmationDialog(
                    "Remove this photo?",
                    isPresented: $confirmsRemovingPhoto,
                    titleVisibility: .visible
                ) {
                    Button("Remove Photo", role: .destructive, action: removePhoto)
                } message: {
                    if stickerData != nil {
                        Text("Its sticker will be removed too.")
                    }
                }
            }
        } header: {
            Text("Photo")
        } footer: {
            if let stickerError {
                Text(stickerError)
            }
        }
    }

    /// Clears the photo and everything made from it.
    private func removePhoto() {
        photoData = nil
        stickerData = nil
        stickerPreview = nil
        makesSticker = false
        stickerError = nil
        // The toggle row (and its sticker task) goes away with the photo, so nothing else would
        // clear this and Save would stay blocked.
        isMakingSticker = false
    }

    /// Makes the sticker when the toggle is on and there isn't one for this photo yet, or drops
    /// it when the toggle is off. Runs again whenever the photo or toggle changes, which cancels
    /// a sticker still being made for the old one. SwiftUI cancels the old run only on the next
    /// view update, so a late result is also dropped if the photo or toggle changed meanwhile.
    private func updateSticker() async {
        guard makesSticker, let photoData else {
            stickerData = nil
            isMakingSticker = false
            return
        }
        // Already made for this photo (photo changes clear it).
        guard stickerData == nil else { return }
        let source = photoData

        stickerError = nil
        isMakingSticker = true
        do {
            let sticker = try await StickerMaker.makeSticker(from: photoData)
            guard isCurrent(source) else { return }
            stickerData = sticker
        } catch StickerMaker.StickerError.noSubject {
            guard isCurrent(source) else { return }
            stickerError = "Couldn't find a drink in this photo."
            makesSticker = false
        } catch {
            guard isCurrent(source) else { return }
            stickerError = "Couldn't make a sticker from this photo."
            makesSticker = false
        }
        isMakingSticker = false
    }

    /// Whether a sticker made from `source` still belongs in the form.
    private func isCurrent(_ source: Data) -> Bool {
        !Task.isCancelled && photoData == source && makesSticker
    }
}
