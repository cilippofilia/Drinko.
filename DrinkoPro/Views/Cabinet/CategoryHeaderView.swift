//
//  CategoryHeaderView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 27/01/2024.
//

import SwiftData
import SwiftUI

struct CategoryHeaderView: View {
    let category: Category
    var onEdit: () -> Void

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(category.name)
                .foregroundStyle(Color(category.color))

            Text(category.detail)
                .foregroundStyle(.secondary)
                .lineLimit(2)

            Spacer()

            Button("Edit \(category.name)", systemImage: "square.and.pencil", action: onEdit)
                .labelStyle(.iconOnly)
                .foregroundStyle(Color(category.color))
        }
        .padding(.bottom, 10)
    }
}

#if DEBUG
#Preview {
    do {
        let previewer = try CabinetPreviewerPreviewer()

        return CategoryHeaderView(category: previewer.category, onEdit: {})
            .modelContainer(previewer.container)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
#endif
