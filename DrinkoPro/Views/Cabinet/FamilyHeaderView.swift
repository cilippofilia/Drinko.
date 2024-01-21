//
//  FamilyHeaderView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 23/08/2023.
//

import SwiftUI

struct FamilyHeaderView: View {
    @ObservedObject var family: Family

    var body: some View {
        HStack {
            Text(family.familyName)
                .foregroundColor(Color(family.familyColor))
                .bold()

            Text(family.familyDetail)
                .foregroundColor(Color.secondary)

            Spacer()

            NavigationLink(destination: EditFamilyView(family: family)) {
                Image(systemName: "square.and.pencil")
                    .imageScale(.large)
                    .foregroundColor(Color.secondary)
            }
        }
        .padding(.bottom, 10)
    }
}
