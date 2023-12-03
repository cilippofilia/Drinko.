//
//  SuperJuiceView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 03/10/2023.
//

import SwiftUI

enum CalculationMode: String, CaseIterable {
    case peels = "Peels amount"
    case water = "Water amount"
}

struct SuperJuiceView: View {
    @State private var selectedMode = CalculationMode.peels
    @State private var peels = ""
    @State private var water = ""

    @State private var citricAcid: Double = 0
    @State private var malicAcid: Double = 0
    @State private var waterAmount: Double = 0
    
    @FocusState private var focusedField: Bool

    let typeOfJuice: String

    var body: some View {
        VStack {
            Picker("Calculation Mode", selection: $selectedMode) {
                ForEach(CalculationMode.allCases, id: \.self) { mode in
                    Text(mode.rawValue)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)

            Form {
                Section(header: Text(selectedMode == .peels ? "\(typeOfJuice) peels (gr)" : "Water (ml)")) {
                    Group {
                        if selectedMode == .peels {
                            TextField("\(typeOfJuice) peels in grams", text: $peels)
                                .focused($focusedField)
                        } else {
                            TextField("Water amount in millilitres", text: $water)
                                .focused($focusedField)

                        }
                    }
                    .keyboardType(.decimalPad)
                }

                Section {
                    if typeOfJuice == "Lime" {
                        limeButton
                    } else {
                        lemonButton
                    }
                }

                Section(footer: Text("Remember to add the juice of the peeled fruits used to make superjuice. The final volume will be a bit higher than the water volume displayed.")) {
                    if selectedMode == .water {
                        Text("\(typeOfJuice) peels:\n") + 
                        Text("\(Double(peels) ?? 0, specifier: "%.2f") gr")
                            .font(.title)
                    }

                    Text("Citric Acid:\n") + 
                    Text("\(citricAcid, specifier: "%.2f") gr")
                        .font(.title)

                    if typeOfJuice == "Lime" {
                        Text("Malic Acid:\n") + 
                        Text("\(malicAcid, specifier: "%.2f") gr")
                            .font(.title)
                    }
                    
                    Text("Water:\n") + 
                    Text("\(waterAmount, specifier: "%.2f") ml")
                        .font(.title)
                }
            }
            .navigationTitle("Juice Calculator")
        }
    }
}

private extension SuperJuiceView {
    var limeButton: some View {
        Button(action: {
            if selectedMode == .peels {
                guard !peels.isEmpty else { return peels = "0" }

                citricAcid = 0.66 * Double(peels)!
                malicAcid = 0.33 * Double(peels)!
                waterAmount = 16.66 * Double(peels)!
            }
            if selectedMode == .water {
                guard !water.isEmpty else { return water = "0" }

                waterAmount = Double(water)!
                peels = String(waterAmount / 16.66)
                citricAcid = 0.66 * Double(peels)!
                malicAcid = 0.33 * Double(peels)!
            }
        
            focusedField = false
        }) {
            Text("Calculate")
        }
    }

    var lemonButton: some View {
        Button(action: {
            if selectedMode == .peels {
                guard !peels.isEmpty else { return peels = "0" }

                citricAcid = 1 * Double(peels)!
                waterAmount = 16.66 * Double(peels)!
            }
            if selectedMode == .water {
                guard !water.isEmpty else { return water = "0" }

                waterAmount = Double(water)!
                peels = String(waterAmount / 16.66)
                citricAcid = 1 * Double(peels)!
            }
            
            focusedField = false
        }) {
            Text("Calculate")
        }
    }
}

#Preview {
    SuperJuiceView(typeOfJuice: "Lime")
        .preferredColorScheme(.dark)
}
