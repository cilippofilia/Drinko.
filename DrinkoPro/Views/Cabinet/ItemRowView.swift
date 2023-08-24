//
//  ItemRowView.swift
//  Drinko
//
//  Created by Filippo Cilia on 05/02/2021.
//

import SwiftUI

struct ItemRowView: View {
    @ObservedObject var favoriteProducts = FavoriteProduct()

    @ObservedObject var family: Family
    @ObservedObject var item: Item

    @State private var displayEditProductView = false
        
    var body: some View {
        NavigationLink(destination: EditItemView(item: item)) {
            HStack {
                Image(systemName: "cart")
                    .foregroundColor(favoriteProducts.contains(item) ? Color.secondary : Color.clear)
                    .animation(.easeOut, value: item)

                VStack(alignment: .leading) {
                    Text(item.itemName)
                        .font(.headline)
                    
                    Text(item.itemAbv)
                        .font(.caption)
                        .bold()
                        .foregroundColor(Color.secondary)
                    + Text("% ABV")
                        .font(.caption)
                        .foregroundColor(Color.secondary)
                }
                
                Spacer()
                
                if !item.tried {
                    HStack {
                        Text("N.A.")
                            .foregroundColor(Color.clear)
                        Image(systemName: "star.fill")
                            .foregroundColor(Color.clear)
                    }
                } else {
                    HStack {
                        Text("\(item.rating)")
                        Image(systemName: "star.fill")
                            .foregroundColor(Color.yellow)
                    }
                }
            }
        }
    }
}

// THIS PREVIEW IS NOT WORKING
//#if DEBUG
//struct ItemRowView_Previews: PreviewProvider {
//    static var previews: some View {
//        ItemRowView(item: Item.example)
//            .environmentObject()
//    }
//}
//#endif
