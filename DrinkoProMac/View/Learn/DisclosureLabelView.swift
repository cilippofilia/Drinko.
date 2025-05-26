//
//  DisclosureLabelView.swift
//  DrinkoProMac
//
//  Created by Filippo Cilia on 24/05/2025.
//

import SwiftUI

struct DisclosureLabelView: View {
    let topic: String

    var body: some View {
        Text(topic.replacingOccurrences(of: "-", with: " ").capitalized)
            .padding(.horizontal, 6)
            .foregroundStyle(Color.secondary)
    }
}

#Preview {
    DisclosureLabelView(topic: "Preview")
}
