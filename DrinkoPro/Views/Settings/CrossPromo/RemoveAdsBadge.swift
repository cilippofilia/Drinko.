//
//  RemoveAdsBadge.swift
//  DrinkoPro
//

import SwiftUI

struct RemoveAdsBadge: View {
    let size: CGFloat

    init(size: CGFloat = 44) {
        self.size = size
    }

    var body: some View {
        ZStack {
            Text("Ads")
                .foregroundStyle(.black)
            Image(systemName: "nosign")
                .font(.system(size: size))
                .foregroundStyle(.red)
        }
        .background {
            Rectangle().fill(.white)
        }
    }
}

#Preview {
    RemoveAdsBadge()
}
