//
//  DetailsView.swift
//  DrinkoMac
//
//  Created by Filippo Cilia on 23/12/2025.
//

import SwiftData
import SwiftUI

struct DetailsView: View {
    @Bindable var product: Item
    @Environment(\.modelContext) private var modelContext

    @State private var showingDeleteConfirmation: Bool = false
    @State private var isAnimated: Bool = false

    var offImage: Image?
    var onImage = Image(systemName: "star.fill")

    var body: some View {
        Form {
            Section {
                // Product info
                Group {
                    Text("Product name:")
                    TextField("", text: $product.name)
                }
                // ABV
                Group {
                    HStack {
                        TextField("", text: $product.abv)
                        Text("% ABV")
                    }
                }
                // made in
                Group {
                    HStack {
                        Image(systemName: "flag")
                        Text("Made in:")
                    }
                    TextField("", text: $product.madeIn)
                }
                // details
                Group {
                    Text("Details:")
                    TextField(
                        "",
                        text: $product.detail,
                        axis: .vertical
                    )
                }
                // review
                Group {
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
                    }
                }

                Section {
                    Button(action: {
                        showingDeleteConfirmation = true
                    }) {
                        Label("Delete Product", systemImage: "trash")
                            .foregroundStyle(.red)
                    }
                } footer: {
                    Text("By deleting the product you will be deleting every informations added to it.")
                        .font(.caption)
                }
            }
            .padding(.horizontal)
        }
        .alert("Delete product?", isPresented: $showingDeleteConfirmation) {
            Button("Delete", role: .destructive) { delete() }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to delete this product?\nYou will delete all the informations added to it.")
        }
    }

    func image(for n: Int) -> Image {
        if n > product.rating {
            return offImage ?? onImage
        } else {
            return onImage
        }
    }

    func delete() {
        modelContext.delete(product)
    }
}

#if DEBUG
#Preview {
    do {
        let previewer = try Previewer()

        return DetailsView(product: Item(name: "Absolut Vodka", detail: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.", madeIn: "Poland", abv: "45", rating: 5, tried: false, creationDate: Date.now))
            .modelContainer(previewer.container)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
#endif
