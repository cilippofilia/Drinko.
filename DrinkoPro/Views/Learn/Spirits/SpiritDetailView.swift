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
            VStack {
                Image(spirit.image)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 280)
                    .clipped()

                VStack(spacing: 10) {
                    Text(spirit.title)
                        .font(.title)
                        .bold()

                    Text(spirit.description)
                        .font(.headline)
                        .foregroundColor(.secondary)

                    Text(spirit.body)
                }
                .frame(maxWidth: screenWidthPlusMargins)
                .padding(.bottom)
            }
        }
        .navigationBarTitle(spirit.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#if DEBUG
struct SpiritDetailView_Previews: PreviewProvider {
    static var previews: some View {
        SpiritDetailView(spirit: .example)
    }
}
#endif
