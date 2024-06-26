//
//  EditProductView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 04/02/2024.
//

import SwiftUI

struct EditProductView: View {
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
            Section {
                TextField("Product name", text: $product.name)
                    .focused($isFocused)
                HStack {
                    TextField("ABV", text: $product.abv)
                        .frame(width: 33)
                        .keyboardType(.decimalPad)
                        .focused($isFocused)

                    Text("% ABV")
                    Spacer()
                }
                
                HStack {
                    Image(systemName: "flag")
                    TextField("Made in", text: $product.madeIn)
                        .focused($isFocused)
                }
            }
            
            Section(header: Text("Rating")) {
                Toggle(isOn: $product.tried) {
                    Text("Have you tried it yet?")
                }

                HStack {
                    Spacer()
                    
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
            }

            Section(header: Text("Notes")) {
                TextField(
                    "Your notes on \(product.name)...",
                    text: $product.detail,
                    axis: .vertical
                )
                .focused($isFocused)
            }
            
            Section(footer: Text("By deleting the product you will be deleting every informations added to it.")) {
                Button(action: {
                    showingDeleteConfirmation = true
                }) {
                    Label("Delete Product", systemImage: "trash")
                        .foregroundStyle(.red)
                }
            }
        }
        .navigationTitle("Edit Product")
        .alert("Delete product?", isPresented: $showingDeleteConfirmation) {
            Button("Delete", role: .destructive) { delete() }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to delete this product? You will delete all the informations added to it.")
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()

                Button("Done") {
                    isFocused = false
                }
            }
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
        dismiss()
    }
}

#if DEBUG
#Preview {
    do {
        let previewer = try Previewer()
        
        return EditProductView(product: Item(name: "Absolut Vodka", detail: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.", madeIn: "Poland", abv: "45", rating: 5, tried: false, creationDate: Date.now))
            .modelContainer(previewer.container)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
#endif
