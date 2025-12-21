//
//  LessonRowView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 27/04/2023.
//

import SwiftUI

struct LessonRowView: View {
    @Environment(\.horizontalSizeClass) var sizeClass
    let lesson: Lesson

    var spacing: CGFloat {
        #if os(iOS)
        sizeClass == .compact ? 10 : 20
        #else
        10
        #endif
    }

    var body: some View {
        HStack(spacing: spacing) {
            AsyncImage(url: URL(string: lesson.image)) { state in
                switch state {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure:
                    ImageFailedToLoad()
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
