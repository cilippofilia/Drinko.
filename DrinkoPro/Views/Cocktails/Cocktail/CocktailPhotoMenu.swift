//
//  CocktailPhotoMenu.swift
//  DrinkoPro
//

import PhotosUI
import SwiftUI

/// Hands back the photo already shrunk for storage.
struct CocktailPhotoMenu<Label: View>: View {
    let onPick: (Data) -> Void
    @ViewBuilder let label: Label

    @State private var showsLibrary = false
    @State private var showsCamera = false
    @State private var pickerItem: PhotosPickerItem?
    @State private var showsError = false
    /// A picked photo may have to download from iCloud first.
    @State private var isLoading = false

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
            if isLoading {
                ProgressView()
            } else {
                label
            }
        }
        // No second pick while one is still loading.
        .disabled(isLoading)
        .photosPicker(isPresented: $showsLibrary, selection: $pickerItem, matching: .images)
        .onChange(of: pickerItem) { _, item in
            guard let item else { return }
            pickerItem = nil
            load { try await item.loadTransferable(type: Data.self) }
        }
        #if os(iOS)
        .fullScreenCover(isPresented: $showsCamera) {
            CameraPicker { data in
                load { data }
            }
            .ignoresSafeArea()
        }
        #endif
        .alert("Couldn't add the photo.", isPresented: $showsError) {
            Button("OK", role: .cancel) { }
        }
    }

    private func load(_ fetch: @escaping () async throws -> Data?) {
        isLoading = true
        Task {
            defer { isLoading = false }
            do {
                guard let data = try await fetch() else {
                    showsError = true
                    return
                }
                onPick(try await UserPhotoProcessor.processedJPEG(from: data))
            } catch {
                showsError = true
            }
        }
    }
}
