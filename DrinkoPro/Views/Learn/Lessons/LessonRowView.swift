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
                AsyncImage(url: URL(string: lesson.img)) { phase in
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
