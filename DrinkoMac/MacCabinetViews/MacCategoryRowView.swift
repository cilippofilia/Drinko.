//
//  MacCategoryRowView.swift
//  DrinkoMac
//
//  Created by Filippo Cilia on 21/01/2026.
//

import SwiftUI

struct MacCategoryRowView: View {
    let name: String
    let color: String
    let buttonAction: () -> Void

    var body: some View {
        HStack {
            Text(name)
            Spacer()
            Button {
                buttonAction()
            } label: {
                Label("Edit", systemImage: "square.and.pencil")
                    .labelStyle(.iconOnly)
            }
            .buttonStyle(.plain)
        }
        .font(.headline)
        .foregroundStyle(Color(color))
        .padding(.horizontal)
        .padding(.vertical, 4)
    }
}

#Preview {
    MacCategoryRowView(name: "TEST", color: "", buttonAction: { })
}
