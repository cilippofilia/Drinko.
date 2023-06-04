//
//  SpiritRowView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 02/05/2023.
//

import SwiftUI

struct SpiritRowView: View {
    var spirit: Spirit

    var body: some View {
        NavigationLink(destination: SpiritDetailView(spirit: spirit)) {
            HStack {
                Image(spirit.image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 45, height: 45)
                    .cornerRadius(10)

                VStack(alignment: .leading) {
                    Text(spirit.title)
                        .font(.headline)  
                }
            }
        }
        .frame(height: 45)
    }
}

//struct SpiritRowView_Previews: PreviewProvider {
//    static var previews: some View {
//        SpiritRowView(spirit: .example)
//    }
//}
