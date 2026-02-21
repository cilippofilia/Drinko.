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
    let editAction: () -> Void
    let deleteAction: () -> Void

    var body: some View {
        HStack {
            Button(action: {
                editAction()
            }) {
                VStack(alignment: .leading) {
                    Text(category.name)
                        .foregroundStyle(Color(category.color))
                        .font(.headline)
                    Text(category.detail)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(.rect)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Edit \(category.name)")

            DeleteButtonView(
                label: "Delete",
                action: {
                    deleteAction()
                }
            )
            .labelStyle(.iconOnly)
            .foregroundStyle(.red)
            .accessibilityLabel("Delete \(category.name)")
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
        return MacCategoryRowView(category: previewer.category, editAction: { }, deleteAction: { })
            .modelContainer(previewer.container)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
#endif
