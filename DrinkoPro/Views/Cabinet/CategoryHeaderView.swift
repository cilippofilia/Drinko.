//
//  CategoryHeaderView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 27/01/2024.
//

import SwiftUI

struct CategoryHeaderView: View {
    let category: Category
    
    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(category.name)
                .foregroundStyle(Color(category.color))

            Text(category.detail)
                .foregroundStyle(.secondary)
            
            Spacer()
            
            NavigationLink(value: category) {
                Image(systemName: "square.and.pencil")
                    .foregroundStyle(Color(category.color))
            }
        }
        .fontWeight(.medium)
        .padding(.bottom, 10)
        .accessibilityElement(children: .combine)
    }
}

#if DEBUG
#Preview {
    do {
        let previewer = try Previewer()
        
        return CategoryHeaderView(category: previewer.category)
            .modelContainer(previewer.container)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
#endif
