//
//  ImageSuccesful.swift
//  DrinkoProMac
//
//  Created by Filippo Cilia on 24/05/2025.
//

import SwiftUI

struct ImageSuccesful: View {
    let image: Image

    var body: some View {
        image
            .resizable()
            .scaledToFill()
    }
}

#if DEBUG
#Preview {
    ImageSuccesful(image: Image("lemon"))
}
#endif
