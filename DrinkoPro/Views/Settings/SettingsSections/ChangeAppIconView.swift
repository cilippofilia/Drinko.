//
//  ChangeAppIconView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 21/06/2024.
//

import SwiftUI

struct ChangeAppIconView: View {
    @StateObject var viewModel: ChangeAppIconViewModel
    @State private var isSelected: Bool = false

    var body: some View {
        List {
            ForEach(AppIcon.allCases) { appIcon in
                Button(action: { 
                    withAnimation {
                        viewModel.updateAppIcon(to: appIcon)
                        isSelected.toggle()
                    }
                }) {
                    HStack {
                        Image(uiImage: appIcon.preview)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 60, height: 60)
                            .cornerRadius(12)

                        Text(appIcon.description)
                        
                        Spacer()
                        
                        if UIApplication.shared.alternateIconName == appIcon.id {
                            Image(systemName: "checkmark")
                                .font(.title3)
                                .foregroundStyle(Color.secondary)
                                .symbolEffect(.bounce.up, value: isSelected)
                        }
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .navigationTitle("App icons")
    }
}

struct ChangeAppIconView_Previews: PreviewProvider {
    static var previews: some View {
        ChangeAppIconView(viewModel: ChangeAppIconViewModel())
    }
}
