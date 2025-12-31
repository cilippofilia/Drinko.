//
//  ProductListView.swift
//  DrinkoMac
//
//  Created by Filippo Cilia on 23/12/2025.
//

import SwiftData
import SwiftUI

struct ProductListView: View {
    @Bindable var product: Item
    @State private var isAnimated: Bool = false
    @State private var showingDeleteConfirmation: Bool = false
    @State private var isDeleteEnabled: Bool = false

    let deleteAction: ActionVoid?

    var body: some View {
        List {
            // Product Information Section
            Section {
                VStack(alignment: .leading) {
                    Label("Product Name", systemImage: "tag")
                        .font(.headline)
                    TextField("Insert name here", text: $product.name)
                        .textFieldStyle(.roundedBorder)
                }

                HStack(spacing: 60) {
                    VStack(alignment: .leading) {
                        Label("Alcohol Content", systemImage: "drop")
                            .font(.headline)
                        HStack {
                            TextField("0.0", text: $product.abv)
                                .textFieldStyle(.roundedBorder)
                                .frame(width: 80)
                            Text("% ABV")
                                .foregroundStyle(.secondary)
                        }
                    }

                    VStack(alignment: .leading) {
                        Label("Origin", systemImage: "flag")
                            .font(.headline)
                        TextField("Country or region", text: $product.madeIn)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 160)
                    }
                }
            } header: {
                Text("Basic Information")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
            }
            .listRowSeparator(.hidden)
            .animation(.easeInOut, value: product.tried)

            Section {
                VStack(alignment: .leading) {
                    Label("Product Details", systemImage: "text.alignleft")
                        .font(.headline)

                    TextField(
                        "Add any additional notes or description...",
                        text: $product.detail,
                        axis: .vertical
                    )
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(5...10)
                }

                Toggle(isOn: $product.tried) {
                    Label("I've tried this product", systemImage: "checkmark.circle")
                        .font(.headline)
                }
                .toggleStyle(.switch)

                if product.tried {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Your Rating")
                            .font(.headline)
                            .foregroundStyle(.secondary)

                        HStack(spacing: 12) {
                            ForEach(1..<6) { star in
                                image(for: star)
                                    .font(.title2)
                                    .foregroundStyle(star > product.rating ? Color.secondary.opacity(0.3) : Color.yellow)
                                    .onTapGesture {
                                        product.rating = star
                                        isAnimated.toggle()
                                    }
                                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isAnimated)
                                    .symbolEffect(.bounce.up, value: isAnimated)
                                    .contentTransition(.symbolEffect(.replace))
                            }

                            if product.rating > 0 {
                                Text("\(product.rating) star\(product.rating == 1 ? "" : "s")")
                                    .foregroundStyle(.secondary)
                                    .font(.subheadline)
                            }
                        }
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            } header: {
                Text("Review")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
            }
            .listRowSeparator(.hidden)

            // Delete Product
            Section {
                Button("Delete Product", systemImage: "trash") {
                    showingDeleteConfirmation = true
                }
                .foregroundStyle(.red)
                .buttonStyle(.plain)
                .padding(.vertical, 4)
            } footer: {
                Text("Deleting this product will permanently remove all associated information. This action cannot be undone.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .listRowSeparator(.hidden)
        }
        .alert("Delete Product", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                if let action = deleteAction {
                    action()
                }
            }
        } message: {
            Text("Are you sure you want to delete '\(product.name)'? This action cannot be undone.")
        }
    }

    private func image(for number: Int) -> Image {
        if number > product.rating {
            return Image(systemName: "star")
        } else if number == product.rating {
            return Image(systemName: "star.fill")
        } else {
            return Image(systemName: "star.fill")
        }
    }
}

#if DEBUG
#Preview {
    if let previewer = try? Previewer() {
        ProductListView(
            product: Item(
                name: "Absolut Vodka",
                detail: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
                madeIn: "Poland",
                abv: "45",
                rating: 5,
                tried: false,
                creationDate: Date.now,
                isFavorite: true
            ),
            deleteAction: { }
        )
        .modelContainer(previewer.container)
    } else {
        Text("Failed to create preview")
    }
}
#endif
