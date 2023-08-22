//
//  ItemDetailView.swift
//  Drinko
//
//  Created by Filippo Cilia on 05/02/2021.
//

import SwiftUI

struct EditItemView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) var managedObjectContext
    @EnvironmentObject var dataController: DataController
    @ObservedObject var favoriteProducts = FavoriteProduct()

    @State private var name: String
    @State private var detail: String
    @State private var abv: String
    @State private var rating: Int
    @State private var tried: Bool
    @State private var madeIn: String
    @State private var showingDeleteConfirm = false
    
    var offImage: Image?
    var onImage = Image(systemName: "star.fill")
    
    let item: Item
    
    init(item: Item) {
        self.item = item
        
        _name = State(wrappedValue: item.itemName)
        _detail = State(wrappedValue: item.itemDetail)
        _abv = State(wrappedValue: item.itemAbv)
        _rating = State(wrappedValue: Int(item.rating))
        _tried = State(wrappedValue: item.tried)
        _madeIn = State(wrappedValue: item.itemMadeIn)
    }
    
    var body: some View {
        Form {
            Section(header: Text("Product")) {
                TextField("Product name", text: $name.onChange(update))
                
                HStack {
                    TextField("ABV", text: $abv.onChange(update))
                        .frame(width: 50)
                        .keyboardType(.decimalPad)
                    
                    Text("% ABV")
                    Spacer()
                }
                
                HStack {
                    Image(systemName: "flag")
                    
                    TextField("Made in", text: $madeIn.onChange(update))
                }
            }
            
            Section(header: Text("Rating")) {
                Toggle(isOn: $tried.onChange(update)) {
                    Text("Have you tried it yet?")
                }

                HStack {
                    Spacer()
                    
                    ForEach(1 ..< 5 + 1) { star in
                        image(for: star)
                            .foregroundColor(star > rating ? Color.secondary : Color.yellow)
                            .onTapGesture {
                                rating = star
                                update()
                            }
                    }
                    
                    Spacer()
                }
            }
            
            Section(header: Text("Notes")) {
                TextEditor(text: $detail.onChange(update))
                    .frame(minHeight: 200, maxHeight: 400)
            }

            Section(footer: Text("By deleting the product you will be deleting every informations added to it.")) {
                Button(action: {
                    update()
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Image(systemName: "checkmark.circle")

                        Text("Save Changes")
                    }
                }
                
                Button(action: {
                    showingDeleteConfirm = true
                }) {
                    HStack {
                        Image(systemName: "trash")
                            
                        Text("Delete Product")
                    }
                }
                .accentColor(.red)
            }
        }
        .navigationBarTitle(Text(item.itemName), displayMode: .inline)
        .onDisappear(perform: dataController.save)
        .alert(isPresented: $showingDeleteConfirm) {
            Alert(
                title: Text("Delete product?"),
                message: Text("Are you sure you want to delete this product? You will delete all the informations added to it."),
                primaryButton: .default(Text("Delete"), action: delete),
                secondaryButton: .cancel()
            )
        }

    }
    
    func update() {
        item.family?.objectWillChange.send()
        
        item.name = name
        item.detail = detail
        item.abv = abv
        item.rating = Int16(rating)
        item.tried = tried
        item.madeIn = madeIn
    }
    
    func delete() {
        dataController.delete(item)
        presentationMode.wrappedValue.dismiss()
    }

    func image(for n: Int) -> Image {
        if n > rating {
            return offImage ?? onImage
        } else {
            return onImage
        }
    }
}
