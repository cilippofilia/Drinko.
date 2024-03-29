//
//  SuperjuiceRowView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 10/10/2023.
//

import SwiftUI

struct SuperjuiceRowView: View {
    @Environment(\.horizontalSizeClass) var sizeClass

    @State private var rowHeight: CGFloat = 45
    @State private var corners: CGFloat = 10

    let juiceType: String

    var body: some View {
        NavigationLink(destination: SuperJuiceView(typeOfJuice: juiceType)) {
            HStack(spacing: sizeClass == .compact ? 10 : 20) {
                imageURL

                VStack(alignment: .leading) {
                    Text("\(juiceType.capitalizingFirstLetter()) Superjuice")
                        .font(.headline)
                }
            }
        }
        .frame(height: 45)
    }
}

private extension SuperjuiceRowView {
    var imageURL: some View {
        AsyncImage(url: URL(string:         "https://raw.githubusercontent.com/cilippofilia/drinko-learn-pics/main/\(juiceType)s.jpg"
)) { phase in
            switch phase {
                case .failure:
                    imageFailedToLoad
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                default:
                    ProgressView()
            }
        }
        .frame(width: rowHeight,
               height: rowHeight)
        .cornerRadius(corners)
    }
}

#Preview {
    SuperjuiceRowView(juiceType: "Lime")
}
