//
//  DeleteButtonView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 11/02/2026.
//

import SwiftUI

struct DeleteButtonView: View {
    let label: String
    let action: () -> Void

    var body: some View {
        Button(role: .destructive) {
            action()
        } label: {
            Label(label, systemImage: "trash")
        }
    }
}

#Preview {
    DeleteButtonView(label: "Delete", action: { })
}
