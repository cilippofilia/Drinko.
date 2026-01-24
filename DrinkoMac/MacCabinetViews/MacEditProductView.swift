//
//  MacEditProductView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 24/01/2026.
//

import SwiftData
import SwiftUI

struct MacEditProductView: View {
    @Bindable var product: Item
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @FocusState private var isFocused: Bool
    @State private var showingDeleteConfirmation: Bool = false
    @State private var isAnimated: Bool = false
    
    var offImage: Image?
    var onImage = Image(systemName: "star.fill")

    var body: some View {
        Form {
            Section("Info") {
                TextField("", text: $product.name)
                    .textContentType(.name)
                    .overlay(alignment: .leading) {
                        Text("Product Name")
                            .foregroundStyle(.secondary)
                            .opacity(product.name.isEmpty ? 0.3 : 0)
                            .padding(.leading)
                    }

                HStack {
                    TextField("", text: $product.abv)
                        .frame(width: 50)

                    Text("% ABV")
                    Spacer()
                }

                TextField("", text: $product.madeIn)
                    .overlay(alignment: .leading) {
                        HStack {
                            Image(systemName: "flag")
                            Text("Made in")
                        }
                        .foregroundStyle(.secondary)
                        .opacity(product.madeIn.isEmpty ? 0.3 : 0)
                        .padding(.leading)
                    }
            }
            
            Section {
                Toggle(isOn: $product.tried) {
                    Text("Have you tried it yet?")
                }

                HStack {
                    ForEach(1 ..< 5 + 1) { star in
                        image(for: star)
                            .foregroundColor(star > product.rating ? Color.secondary : Color.yellow)
                            .onTapGesture {
                                product.rating = star
                                isAnimated.toggle()
                            }
                            .animation(.default, value: isAnimated)
                            .symbolEffect(.bounce.up, value: isAnimated)
                    }
                    
                    Spacer()
                }
            } header: {
                Text("Rating")
                    .padding(.top)
            }

            Section {
                TextField(
                    "",
                    text: $product.detail,
                    axis: .vertical
                )
                .overlay(alignment: .leading) {
                    Text("Your notes on \(product.name)...")
                        .foregroundStyle(.secondary)
                        .opacity(product.detail.isEmpty ? 0.3 : 0)
                        .padding(.leading)
                }
            } header: {
                Text("Notes")
                    .padding(.top)
            }

            Section {
                HStack {
                    Button("Save Changes") {
                        save()
                    }

                    Button(
                        "Delete Category",
                        systemImage: "trash",
                        role: .destructive
                    ) {
                        showingDeleteConfirmation.toggle()
                    }
                    .foregroundStyle(.red)
                }
            } footer: {
                Text("By deleting the category you will be deleting every product inside it.")
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .navigationTitle("Edit Product")
        .alert("Delete product?", isPresented: $showingDeleteConfirmation) {
            Button("Delete", role: .destructive) { delete() }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to delete this product? You will delete all the informations added to it.")
        }
    }
    
    func image(for n: Int) -> Image {
        if n > product.rating {
            return offImage ?? onImage
        } else {
            return onImage
        }
    }

    private func save() {
        dismiss()
    }

    func delete() {
        modelContext.delete(product)
        dismiss()
    }
}

#if DEBUG
#Preview {
    do {
        let previewer = try Previewer()
        
        return MacEditProductView(product: Item(name: "Absolut Vodka", detail: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.", madeIn: "", abv: "45", rating: 5, tried: false, creationDate: Date.now))
            .modelContainer(previewer.container)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
#endif
