//
//  MacCategoryRowView.swift
//  DrinkoMac
//
//  Created by Filippo Cilia on 21/01/2026.
//

import SwiftData
import SwiftUI

struct MacCategoryRowView: View {
    let category: Category
    let action: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(category.name)
                    .foregroundStyle(Color(category.color))
                    .font(.headline)

                Text(category.detail)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()

            Button(action: {
                action()
            }) {
                Image(systemName: "square.and.pencil")
                    .foregroundStyle(Color(category.color))
                    .font(.headline)
            }
            .accessibilityLabel("Edit \(category.name)")
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
        .accessibilityElement(children: .contain)
    }
}

#if DEBUG
#Preview {
    do {
        let previewer = try CabinetPreviewerPreviewer()

        return MacCategoryRowView(category: previewer.category, action: { })
            .modelContainer(previewer.container)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
#endif
