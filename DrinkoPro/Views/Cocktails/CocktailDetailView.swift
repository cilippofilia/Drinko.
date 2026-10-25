//
//  CocktailDetailView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 23/04/2023.
//

import SwiftUI

struct CocktailDetailView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.locale) private var locale
    @Environment(CocktailsViewModel.self) private var viewModel

    @AppStorage(CocktailUnitPreference.storageKey) private var unitPreference: CocktailUnitPreference = .automatic
    @AppStorage(DetailSection.storageKey) private var collapsedSections = CollapsedSections()
    @State private var showDeleteConfirmation = false
    @State private var showEditSheet = false
    /// Picked once per visit so the share text doesn't change while the share sheet is open.
    @State private var shareMessageVariant = CocktailShareMessage.randomVariant()

    let cocktail: Cocktail

    var toolbarPlacement: ToolbarItemPlacement {
        #if os(iOS)
        .topBarTrailing
        #elseif os(macOS)
        .automatic
        #endif
    }

    private var activeCocktail: Cocktail {
        viewModel.cocktail(withID: cocktail.id, fallback: cocktail)
    }

    private var shareItem: CocktailShareItem {
        var item = CocktailShareItem(
            cocktail: activeCocktail,
            artwork: viewModel.cardModel(for: activeCocktail).image,
            tint: viewModel.stickerTint(for: activeCocktail),
            selectedUnit: unitPreference.unit(for: locale),
            showsOriginalUnits: viewModel.isUserCreated(activeCocktail)
        )
        if case .userPhoto(let id, let revision) = item.artwork {
            let viewModel = viewModel
            item.loadUserPhoto = {
                // The stored size, so the 1080 px wide banner fills from a sharp source.
                viewModel.photoThumbnail(
                    for: id,
                    revision: revision,
                    maxPixelSize: UserPhotoProcessor.maxStoredPixelSize
                )
            }
        }
        if case .userSticker(let id, let revision, _) = item.artwork {
            let viewModel = viewModel
            item.loadUserSticker = {
                // Full size, so the 1080 px wide banner fills from a sharp source.
                viewModel.stickerThumbnail(
                    for: id,
                    revision: revision,
                    maxPixelSize: Int(StickerMaker.maxLongSide)
                )
            }
        }
        return item
    }

    var body: some View {
        let linkedCocktails = viewModel.getLinkedCocktails(for: activeCocktail)

        ScrollView {
            VStack(spacing: detailCardInset) {
                CocktailImageHeader(
                    cocktail: activeCocktail,
                    history: viewModel.getCocktailHistory(for: activeCocktail)
                )

                DetailSectionCard(
                    title: "Ingredients",
                    isCollapsed: isCollapsed(.ingredients),
                    toggle: { toggle(.ingredients) },
                    content: {
                        CocktailDetailsSection(
                            cocktail: activeCocktail,
                            selectedUnit: unitPreference.unit(for: locale),
                            showsOriginalUnits: viewModel.isUserCreated(activeCocktail)
                        )
                    }
                )

                if let procedure = viewModel.getCocktailProcedure(for: activeCocktail) {
                    DetailSectionCard(
                        title: "Procedure",
                        isCollapsed: isCollapsed(.procedure),
                        toggle: { toggle(.procedure) },
                        content: {
                            ProcedureView(cocktail: activeCocktail, procedure: procedure)
                        }
                    )
                }

                if !linkedCocktails.isEmpty {
                    DetailSectionCard(
                        title: "You may also like",
                        isCollapsed: isCollapsed(.suggested),
                        toggle: { toggle(.suggested) },
                        content: {
                            LinkedCocktailsView(cocktails: linkedCocktails)
                        }
                    )
                }

                if viewModel.isUserCreated(activeCocktail) {
                    DeleteButtonView(
                        label: "Delete",
                        action: {
                            showDeleteConfirmation = true
                        }
                    )
                    .foregroundStyle(.red)
                    .buttonStyle(.bordered)
                    .padding(.top)
                }

                Spacer(minLength: 50)
            }
            .padding(.horizontal)
            .frame(maxWidth: readableContentWidth)
            .frame(maxWidth: .infinity)
        }
        .navigationTitle(activeCocktail.name)
        .scrollIndicators(.hidden, axes: .vertical)
        .scrollBounceBehavior(.basedOnSize)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            ToolbarItem(placement: toolbarPlacement) {
                ShareLink(
                    item: shareItem,
                    message: CocktailShareMessage.text(for: activeCocktail, variant: shareMessageVariant)
                        .map { Text($0) },
                    preview: SharePreview(activeCocktail.name, image: Image("logo"))
                ) {
                    Label("Share Recipe Card", systemImage: "square.and.arrow.up")
                }
            }
            if viewModel.isUserCreated(activeCocktail) {
                ToolbarItem(placement: toolbarPlacement) {
                    Button("Edit Cocktail", systemImage: "pencil.line") {
                        showEditSheet = true
                    }
                    .accessibilityHint("Edits this cocktail")
                }
            }
        }
        .sheet(isPresented: $showEditSheet) {
            NavigationStack {
                #if os(iOS)
                UserCocktailForm(
                    methodOptions: viewModel.methodOptions(),
                    glassOptions: viewModel.glassOptions(),
                    iceOptions: viewModel.iceOptions(),
                    unitOptions: viewModel.unitOptions(),
                    editingCocktail: activeCocktail,
                    editingProcedureSteps: viewModel.procedureSteps(for: activeCocktail),
                    editingPhotoData: viewModel.photoData(for: activeCocktail),
                    editingStickerData: viewModel.stickerData(for: activeCocktail),
                    editingTintColor: viewModel.pickedTintColor(for: activeCocktail)
                )
                #else
                MacUserCocktailForm(
                    methodOptions: viewModel.methodOptions(),
                    glassOptions: viewModel.glassOptions(),
                    iceOptions: viewModel.iceOptions(),
                    unitOptions: viewModel.unitOptions(),
                    editingCocktail: activeCocktail,
                    editingProcedureSteps: viewModel.procedureSteps(for: activeCocktail),
                    editingPhotoData: viewModel.photoData(for: activeCocktail),
                    editingStickerData: viewModel.stickerData(for: activeCocktail),
                    editingTintColor: viewModel.pickedTintColor(for: activeCocktail)
                )
                #endif
            }
        }
        .alert("Delete Cocktail?", isPresented: $showDeleteConfirmation) {
            DeleteButtonView(
                label: "Delete",
                action: {
                    viewModel.deleteUserCocktail(activeCocktail)
                    dismiss()
                }
            )
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This will permanently remove your cocktail.")
        }
    }

    private func isCollapsed(_ section: DetailSection) -> Bool {
        collapsedSections.contains(section.rawValue)
    }

    private func toggle(_ section: DetailSection) {
        withAnimation {
            collapsedSections.toggle(section.rawValue)
        }
    }
}

#if DEBUG
#Preview("Bundled") {
    NavigationStack {
        CocktailDetailView(cocktail: .example)
            .drinkoPreviewEnvironment()
    }
}

#Preview("User cocktail") {
    NavigationStack {
        CocktailDetailView(cocktail: .userCreatedExample)
            .drinkoPreviewEnvironment()
    }
}
#endif
