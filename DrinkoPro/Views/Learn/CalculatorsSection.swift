//
//  CalculatorsSection.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 20/04/2024.
//

import SwiftUI

struct CalculatorsSection: View {
    @State private var isCollapsed: Bool = false
    
    var body: some View {
        Section {
            ABVRowView()
            if !isCollapsed {
                SuperjuiceRowView(juiceType: "lime")
                SuperjuiceRowView(juiceType: "lemon")
            }
        } header: {
            HStack {
                Image(systemName: "chevron.down")
                    .rotationEffect(Angle(degrees: isCollapsed ? -90 : 0))
                    .animation(.spring(.snappy), value: isCollapsed)
                Text("Calculators")
            }
            .onTapGesture {
                isCollapsed.toggle()
            }
        }
    }
}

#Preview {
    CalculatorsSection()
}
