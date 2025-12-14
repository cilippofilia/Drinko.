//
//  ImageFailedToLoad.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 25/10/2023.
//

import SwiftUI

struct ImageFailedToLoad: View {
    var body: some View {
        Image(systemName: "xmark.octagon.fill")
            .imageScale(.large)
            .symbolRenderingMode(.multicolor)
    }
}

#if DEBUG
#Preview {
    ImageFailedToLoad()
}
#endif
