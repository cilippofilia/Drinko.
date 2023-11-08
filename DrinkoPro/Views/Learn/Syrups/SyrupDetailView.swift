//
//  SyrupDetailView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 08/11/2023.
//

import SwiftUI

struct SyrupDetailView: View {
    @Environment(\.horizontalSizeClass) var sizeClass
    @State private var frameHeight: CGFloat = 280
    @State private var corners: CGFloat = 10
    
    var syrup: Syrup
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            if sizeClass == .compact {
                compactSyrupView
            } else {
                regularSyrupView
            }
        }
        .navigationBarTitle(syrup.title)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    var compactSyrupView: some View {
        VStack {
            AsyncImage(url: URL(string: syrup.image)) { phase in
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
            .frame(width: compactScreenWidth,
                   height: frameHeight)
            .clipped()
            
            VStack(spacing: 10) {
                Text(syrup.title)
                    .font(.title.bold())
                
                Text(syrup.description)
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Text(syrup.body)
            }
            .frame(maxWidth: compactScreenWidth)
            .padding(.bottom)
        }
    }
    
    var regularSyrupView: some View {
        VStack(spacing: 20) {
            AsyncImage(url: URL(string: syrup.image)) { phase in
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
            .frame(height: frameHeight * 1.75)
            .clipped()
            
            VStack(spacing: 20) {
                Text(syrup.title)
                    .font(.title.bold())
                
                Text(syrup.description)
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Text(syrup.body)
            }
            .frame(maxWidth: regularScreenWidth)
            .padding(.bottom)
        }
    }
}

#if DEBUG
#Preview {
    SyrupDetailView(syrup: .example)
}
#endif
