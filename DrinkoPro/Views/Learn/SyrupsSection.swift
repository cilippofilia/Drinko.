//
//  SyrupsSection.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 20/04/2024.
//

import SwiftUI

struct SyrupsSection: View {
    @State private var syrups = Bundle.main.decode([Lesson].self, from: "syrups.json")
    @State private var isPremiumUser: Bool = false
    @State private var isCollapsed: Bool = false

    var body: some View {
        Section {
            ForEach(syrups) { syrup in
                LessonRowView(lesson: syrup)
            }
        } header: {
            HStack {
                Image(systemName: "chevron.down")
                    .rotationEffect(Angle(degrees: isCollapsed ? -90 : 0))
                    .animation(.spring(.snappy), value: isCollapsed)
                
                Text("Syrups")
            }
            .onTapGesture {
                isCollapsed.toggle()
                if isCollapsed {
                    syrups = [syrups[0]]
                } else {
                    syrups = Bundle.main.decode([Lesson].self, from: "syrups.json")
                }
            }
        }
    }
}

#Preview {
    SyrupsSection()
}
