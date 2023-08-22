//
//  ItemDetailView.swift
//  Drinko
//
//  Created by Filippo Cilia on 06/02/2021.
//

import SwiftUI

struct ItemDetailView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @State private var showEditItemView = false
    
    var offImage: Image?
    var onImage = Image(systemName: "star.fill")

    let item: Item
    
    var body: some View {
        ScrollView(.vertical) {
            VStack {
                Text(item.itemName)
                Text("\(item.itemAbv)% ABV")
                Text(item.itemMadeIn)
            }
            
            HStack {
                ForEach(1 ..< 5 + 1) { star in
                    image(for: star)
                        .foregroundColor(star > item.rating ? Color.secondary : Color.yellow)
                }
            }
            
            VStack(alignment: .leading) {
                Text(item.itemDetail)
            }
        }
        .navigationBarItems(trailing: Button(action: {
            showEditItemView = true
        }) {
            Image(systemName: "square.and.pencil")
        })
        .sheet(isPresented: $showEditItemView) {
            EditItemView(item: item).environment(\.managedObjectContext, managedObjectContext)
        }
    }
        
    func image(for n: Int) -> Image {
        if n > item.rating {
            return offImage ?? onImage
        } else {
            return onImage
        }
    }
}

struct ItemDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ItemDetailView(item: Item.example)
    }
}
