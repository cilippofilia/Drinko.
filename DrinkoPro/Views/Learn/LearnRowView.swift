//
//  LearnRowView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 27/04/2023.
//

import SwiftUI

struct LearnRowView: View {
    var lesson: Lesson

    var body: some View {
        NavigationLink(destination: LearnDetailView(lesson: lesson)) {
            HStack {
                Image(lesson.img)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 45, height: 45)
                    .cornerRadius(10)
                
                VStack(alignment: .leading) {
                    Text(lesson.title)
                        .font(.headline)

                    Text(lesson.description.isEmpty ? "N.A." : lesson.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                        .truncationMode(.tail)
                }
            }
        }
        .frame(height: 45)
    }
}

#if DEBUG
struct LearnRowView_Previews: PreviewProvider {
    static var previews: some View {
        LearnRowView(lesson: .example)
    }
}
#endif
