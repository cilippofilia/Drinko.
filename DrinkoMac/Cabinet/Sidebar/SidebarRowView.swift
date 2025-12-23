//
//  SidebarRowView.swift
//  DrinkoMac
//
//  Created by Filippo Cilia on 23/12/2025.
//

import SwiftUI

struct SidebarRowView: View {
    let categoryName: String
    let categoryDetail: String?
    let products: [Item]?
    let color: Color

    var body: some View {
        HStack {
            RoundedRectangle(cornerRadius: 4, style: .continuous)
                .fill(color.gradient)
                .frame(width: 12, height: 12)

            VStack(alignment: .leading, spacing: 2) {
                Text(categoryName)
                    .fontWeight(.medium)

                if let details = categoryDetail,
                   !details.isEmpty {
                    Text(details)
                        .foregroundStyle(.secondary)
                        .font(.caption)
                }
            }

            Spacer()

            if let products = products {
                Text("\(products.count)")
                    .foregroundStyle(.secondary)
                    .font(.caption)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(.quaternary)
                    .clipShape(.capsule)
            }
        }
    }
}

#Preview {
    SidebarRowView(categoryName: "TEST NAME", categoryDetail: "TEST DESCR", products: [], color: .red)
}
