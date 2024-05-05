//
//  LearnHeaderView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 20/04/2024.
//

import SwiftUI

struct LearnHeaderView: View {
    let text: String
    let isCollapsed: Binding<Bool>

    var body: some View {
        HStack {
            Image(systemName: "chevron.down")
                .rotationEffect(Angle(degrees: isCollapsed.wrappedValue ? -90 : 0))
                .animation(.snappy, value: isCollapsed.wrappedValue)
            Text(text)
        }
        .onTapGesture {
            isCollapsed.wrappedValue.toggle()
        }
    }
}

#if DEBUG
#Preview {
    LearnHeaderView(text: "Advanced", isCollapsed: .constant(true))
}
#endif
