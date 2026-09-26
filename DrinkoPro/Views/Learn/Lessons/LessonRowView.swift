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
            CachedRemoteImage(url: URL(string: lesson.image), contentMode: .fill)
            .frame(width: scaledRowHeight, height: scaledRowHeight)
            .clipShape(.rect(cornerRadius: imageCornerRadius))
            .accessibilityHidden(true)

            VStack(alignment: .leading) {
                Text(lesson.title)
                    .font(.headline)

                Text(lesson.description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
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
