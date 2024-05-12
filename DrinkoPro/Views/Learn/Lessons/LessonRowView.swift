//
//  LessonRowView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 27/04/2023.
//

import SwiftUI

struct LessonRowView: View {
    @Environment(\.horizontalSizeClass) var sizeClass

    @State private var rowHeight: CGFloat = 45
    @State private var corners: CGFloat = 10

    var lesson: Lesson

    var body: some View {
        NavigationLink(destination: LessonDetailView(lesson: lesson)) {
            HStack(spacing: sizeClass == .compact ? 10 : 20) {
                CachedImage(
                    url: lesson.img,
                    animation: .easeInOut,
                    transition: .opacity
                ) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()  

                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure:
                        imageFailedToLoad
                        
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(width: rowHeight,
                       height: rowHeight)
                .cornerRadius(corners)

                VStack(alignment: .leading) {
                    Text(lesson.title)
                        .font(.headline)
                    
                    Text(lesson.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                        .truncationMode(.tail)
                }
            }
        }
        .frame(height: rowHeight)
    }
}

#if DEBUG
#Preview {
    LessonRowView(lesson: .example)
}
#endif
