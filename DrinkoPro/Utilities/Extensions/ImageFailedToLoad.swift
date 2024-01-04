//
//  ImageFailure.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 25/10/2023.
//

import SwiftUI

var imageFailedToLoad: some View {
    VStack(spacing: 10) {
        Image(systemName: "icloud.slash.fill")
            .imageScale(.large)
    }
    .foregroundColor(.gray)
}

#if DEBUG
#Preview {
    imageFailedToLoad
}
#endif
