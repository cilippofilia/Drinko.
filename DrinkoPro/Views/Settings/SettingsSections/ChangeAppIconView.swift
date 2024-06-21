//
//  ChangeAppIconView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 21/06/2024.
//

import SwiftUI

struct ChangeAppIconView: View {
    @ObservedObject var viewModel: ChangeAppIconViewModel
    @State private var isSelected: Bool = false

    var body: some View {
        List {
            ForEach(AppIcon.allCases) { appIcon in
                Button(action: { 
                    withAnimation {
                        viewModel.updateAppIcon(to: appIcon)
                    }
                    isSelected.toggle()
                }) {
                    HStack {
                        Image(uiImage: appIcon.preview)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 60, height: 60)
                            .cornerRadius(12)

                        Text(appIcon.description)
                        
                        Spacer()
                        
                        Image(systemName: UIApplication.shared.alternateIconName == appIcon.id || UIApplication.shared.alternateIconName == nil ? "checkmark.circle" : "circle")
                            .font(.title3)
                            .foregroundStyle(UIApplication.shared.alternateIconName == appIcon.id ? Color.secondary : Color.clear)
                            .symbolEffect(.bounce.up, value: isSelected)
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
