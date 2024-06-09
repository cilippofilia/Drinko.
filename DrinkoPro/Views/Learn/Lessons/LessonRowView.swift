//
//  LessonRowView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 27/04/2023.
//

import SwiftUI

struct LessonRowView: View {
    @Environment(\.horizontalSizeClass) var sizeClass

    var lesson: Lesson

    var body: some View {
        HStack(spacing: sizeClass == .compact ? 10 : 20) {
            AsyncImage(url: URL(string: lesson.image)) { state in
                switch state {
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
            .frame(width: rowHeight, height: rowHeight)
            .cornerRadius(imageCornerRadius)

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
        .frame(height: rowHeight)
    }
}

#if DEBUG
#Preview {
    LessonRowView(lesson: .example)
}
#endif
