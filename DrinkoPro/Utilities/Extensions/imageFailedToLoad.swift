//
//  imageFailure.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 25/10/2023.
//

import SwiftUI

var imageFailedToLoad: some View {
    VStack(spacing: 10) {
        Image(systemName: "wifi.slash")
            .imageScale(.large)
    }
    .foregroundColor(.gray)
}

