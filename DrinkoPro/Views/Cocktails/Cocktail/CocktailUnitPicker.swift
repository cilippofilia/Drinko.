//
//  CocktailUnitPicker.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 14/12/2024.
//

import SwiftUI

struct CocktailUnitPicker: View {
    @Environment(\.horizontalSizeClass) var sizeClass
    @Binding var selectedUnit: String
    let units = ["ml", "oz."]

    var pickerPlaceholder: String {
        #if os(iOS)
        "Select unit"
        #else
        ""
        #endif
    }

    var body: some View {
        Picker(pickerPlaceholder, selection: $selectedUnit) {
            ForEach(units, id: \.self) {
                Text($0)
            }
        }
        .pickerStyle(.segmented)
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.bottom)
    }
}

#if DEBUG
#Preview {
    CocktailUnitPicker(selectedUnit: .constant("ml"))
}
#endif
