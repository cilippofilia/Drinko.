//
//  LessonsSection.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 20/04/2024.
//

import SwiftUI

struct LessonsSection: View {
    @State private var basics = Bundle.main.decode([Lesson].self, from: "basics.json")
    @State private var isPremiumUser: Bool = false
    @State private var isCollapsed: Bool = false

    var body: some View {
        Section {
            ForEach(basics) { lesson in
                LessonRowView(lesson: lesson)
            }
            /// `ADVANCED LESSONS`
            /// Customise RowViews to include  `isPremiumUser`
            /// and display new UI for the row
            if isPremiumUser {
                ForEach(basics) { lesson in
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
                
                Text("Basics")
            }
            .onTapGesture {
                isCollapsed.toggle()
                if isCollapsed {
                    basics = [basics[0]]
                } else {
                    basics = Bundle.main.decode([Lesson].self, from: "basics.json")
                }
            }
        }
    }
}

#Preview {
    LessonsSection()
}
