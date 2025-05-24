//
//  ImageFailure.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 25/10/2023.
//

import SwiftUI

var imageFailedToLoad: some View {
    Image(systemName: "xmark.octagon.fill")
        .imageScale(.large)
        .symbolRenderingMode(.multicolor)
}

#if DEBUG
#Preview {
    imageFailedToLoad
}
#endif
