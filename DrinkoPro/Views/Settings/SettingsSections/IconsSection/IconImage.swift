//
//  IconImage.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 17/02/2024.
//

import SwiftUI

struct IconImage: View {
    var icon: Icon
    
    var body: some View {
        Label {
            Text(icon.rawValue)
        } icon: {
            Image(uiImage: UIImage(named: icon.rawValue) ?? UIImage())
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(minHeight: 57, maxHeight: 1024)
                .cornerRadius(18)
                .shadow(radius: 18)
                .padding()
        }
        .labelStyle(.iconOnly)
    }
}

#if DEBUG
#Preview {
    IconImage(icon: .original)
}
#endif
