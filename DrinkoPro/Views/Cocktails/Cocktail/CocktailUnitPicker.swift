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
    
    var body: some View {
        Picker("Select unit", selection: $selectedUnit) {
            ForEach(units, id: \.self) {
                Text($0)
            }
        }
        .pickerStyle(.segmented)
        .containerRelativeFrame(.horizontal) { length, axis in
            sizeClass == .compact ? length * 0.45 : length * 0.35
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.bottom)
    }
}

#if DEBUG
#Preview {
    CocktailUnitPicker(selectedUnit: .constant("ml"))
}
#endif
