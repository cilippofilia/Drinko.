//
//  CocktailPhotoMenu.swift
//  DrinkoPro
//

import PhotosUI
import SwiftUI

/// A menu for adding a photo to a cocktail: take one with the camera (iOS, when there is one)
/// or choose one from the library. Hands back the photo already shrunk for storage, and shows
/// an alert if it can't be read.
struct CocktailPhotoMenu<Label: View>: View {
    let onPick: (Data) -> Void
    @ViewBuilder let label: Label

    @State private var showsLibrary = false
    @State private var showsCamera = false
    @State private var pickerItem: PhotosPickerItem?
    @State private var showsError = false

    init(onPick: @escaping (Data) -> Void, @ViewBuilder label: () -> Label) {
        self.onPick = onPick
        self.label = label()
    }

    var body: some View {
        Menu {
            #if os(iOS)
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                Button("Take Photo", systemImage: "camera") {
                    showsCamera = true
                }
            }
            #endif
            Button("Choose Photo", systemImage: "photo.on.rectangle") {
                showsLibrary = true
            }
        } label: {
            label
        }
        .photosPicker(isPresented: $showsLibrary, selection: $pickerItem, matching: .images)
        .onChange(of: pickerItem) { _, item in
            guard let item else { return }
            pickerItem = nil
            Task {
                do {
                    guard let data = try await item.loadTransferable(type: Data.self) else {
                        showsError = true
                        return
                    }
                    await process(data)
                } catch {
                    showsError = true
                }
            }
        }
        #if os(iOS)
        .fullScreenCover(isPresented: $showsCamera) {
            CameraPicker { data in
                Task { await process(data) }
            }
            .ignoresSafeArea()
        }
        #endif
        .alert("Couldn't add the photo.", isPresented: $showsError) {
            Button("OK", role: .cancel) { }
        }
    }

    private func process(_ data: Data) async {
        do {
            onPick(try await UserPhotoProcessor.processedJPEG(from: data))
        } catch {
            showsError = true
        }
    }
}
