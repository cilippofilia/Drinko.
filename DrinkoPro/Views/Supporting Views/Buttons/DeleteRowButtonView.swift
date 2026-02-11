//
//  DeleteRowButtonView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 11/02/2026.
//

import SwiftUI

struct DeleteRowButtonView: View {
    let action: () -> Void

    var body: some View {
        Button(role: .destructive) {
            action()
        } label: {
            Label("Delete", systemImage: "trash")
        }
    }
}

#Preview {
    DeleteRowButtonView(action: { })
}
