//
//  LessonRowView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 27/04/2023.
//

import SwiftUI

struct LessonRowView: View {
    @Environment(\.horizontalSizeClass) var sizeClass
    @ScaledMetric private var scaledRowHeight: CGFloat = rowHeight

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
                    ImageFailedToLoad()
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: scaledRowHeight, height: scaledRowHeight)
            .cornerRadius(imageCornerRadius)
            .accessibilityHidden(true)

            VStack(alignment: .leading) {
                Text(lesson.title)
                    .font(.headline)
                
                Text(lesson.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    #if os(macOS)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    #endif
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                    .truncationMode(.tail)
            }
        }
        .frame(minHeight: scaledRowHeight)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(lesson.title)
        .accessibilityValue(lesson.description)
    }
}

#if DEBUG
#Preview {
    LessonRowView(lesson: .example)
}
#endif
