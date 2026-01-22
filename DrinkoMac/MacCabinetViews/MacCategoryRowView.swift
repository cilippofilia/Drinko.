//
//  MacCategoryRowView.swift
//  DrinkoMac
//
//  Created by Filippo Cilia on 21/01/2026.
//

import SwiftUI

struct MacCategoryRowView: View {
    let name: String
    let details: String
    let color: String
    let buttonAction: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(name)
                    .foregroundStyle(Color(color))
                    .font(.headline)

                Text(details)
                    .foregroundStyle(.secondary)
                    .font(.caption)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()

            Button {
                buttonAction()
            } label: {
                Label("Edit", systemImage: "square.and.pencil")
                    .labelStyle(.iconOnly)
            }
            .buttonStyle(.plain)
            .foregroundStyle(Color(color))
            .font(.headline)
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
    }
}

#Preview {
    MacCategoryRowView(name: "TEST", details: "DETAILS", color: "", buttonAction: { })
}
