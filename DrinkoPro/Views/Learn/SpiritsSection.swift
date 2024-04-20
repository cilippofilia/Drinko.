//
//  SpiritsSection.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 20/04/2024.
//

import SwiftUI

struct SpiritsSection: View {
    @State private var spirits = Bundle.main.decode([Lesson].self, from: "spirits.json")
    @State private var isPremiumUser: Bool = false
    @State private var isCollapsed: Bool = false

    var body: some View {
        Section {
            ForEach(spirits) { spirit in
                LessonRowView(lesson: spirit)
            }
            /// `ADVANCED SPIRITS`
            /// Customise RowViews to include  `isPremiumUser`
            /// and display new UI for the row
            if isPremiumUser {
                ForEach(spirits) { lesson in
                    // LessonRowView(lesson: lesson)
                    Text("Advanced")
                }
            }
            
            /// `LIQUEURS`
            /// Customise RowViews to include  `isPremiumUser`
            /// and display new UI for the row
            if isPremiumUser {
                ForEach(spirits) { lesson in
                    // LessonRowView(lesson: lesson)
                    Text("Advanced")
                }
            } else {
                Label("Locked", systemImage: "lock")
            }
        } header: {
            HStack {
                Image(systemName: "chevron.down")
                    .rotationEffect(Angle(degrees: isCollapsed ? -90 : 0))
                    .animation(.spring(.snappy), value: isCollapsed)
                
                Text("Spirits")
            }
            .onTapGesture {
                isCollapsed.toggle()
                if isCollapsed {
                    spirits = [spirits[0]]
                } else {
                    spirits = Bundle.main.decode([Lesson].self, from: "spirits.json")
                }
            }
        }
    }
}

#Preview {
    SpiritsSection()
}
