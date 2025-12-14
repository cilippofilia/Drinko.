//
//  ImageSuccesful.swift
//  DrinkoProMac
//
//  Created by Filippo Cilia on 24/05/2025.
//

import SwiftUI

struct ImageSuccesful: View {
    let image: Image
    let aspectRatio: ContentMode

    var body: some View {
        image
            .resizable()
            .aspectRatio(contentMode: aspectRatio)
    }
}

#if DEBUG
#Preview {
    ImageSuccesful(image: Image("lemon"), aspectRatio: .fit)
}
#endif
