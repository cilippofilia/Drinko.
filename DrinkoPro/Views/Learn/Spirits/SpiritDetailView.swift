//
//  SpiritDetailView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 02/05/2023.
//

import SwiftUI

struct SpiritDetailView: View {
    var spirit: Spirit

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 10) {
                Image(spirit.image)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 280)
                    .clipped()

                VStack {
                    Text(spirit.title)
                        .font(.title)
                        .bold()
                        .padding(.vertical)

                    Text(spirit.text)
                        .padding(.vertical)
                }
                .frame(maxWidth: screenWidthPlusMargins)
                .padding(.bottom)
            }
        }
        .navigationBarTitle(spirit.title, displayMode: .inline)
    }
}

struct SpiritDetailView_Previews: PreviewProvider {
    static var previews: some View {
        SpiritDetailView(spirit: .example)
    }
}
