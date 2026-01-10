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
    @FocusState private var isFocused: Bool
    @State private var selectedMode = CalculationMode.peels
    @State private var peels = ""
    @State private var water = ""

    @State private var citricAcid: Double = 0
    @State private var malicAcid: Double = 0
    @State private var waterAmount: Double = 0

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
                Section(header: Text(selectedMode == .peels ? "\(typeOfJuice.capitalizingFirstLetter()) peels (gr)" : "Water (ml)")) {
                    Group {
                        if selectedMode == .peels {
                            TextField("\(typeOfJuice) peels in grams", text: $peels)
                                .focused($isFocused)
                        } else {
                            TextField("Water amount in millilitres", text: $water)
                                .focused($isFocused)
                        }
                    }
                    #if os(iOS)
                    .keyboardType(.decimalPad)
                    #endif
                }

                Section {
                    if typeOfJuice == "lime" {
                        limeButton
                    } else {
                        lemonButton
                    }
                }

                Section(footer: Text("Remember to add the juice of the peeled fruits used to make superjuice. The final volume will be a bit higher than the water volume displayed.")) {
                    if selectedMode == .water {
                        HStack {
                            Text("\(typeOfJuice.capitalizingFirstLetter()) peels: ")
                            Spacer()
                            Text("\(Double(peels) ?? 0, specifier: "%.2f")")
                                .font(.title)
                            Text("gr")
                        }
                    }

                    HStack {
                        Text("Citric Acid: ")
                        Spacer()
                        Text("\(citricAcid, specifier: "%.2f")")
                            .font(.title)
                        Text("gr")
                    }

                    if typeOfJuice == "lime" {
                        HStack {
                            Text("Malic Acid: ")
                            Spacer()
                            Text("\(malicAcid, specifier: "%.2f")")
                                .font(.title)
                            Text("gr")
                        }
                    }
                    
                    HStack {
                        Text("Water: ")
                        Spacer()
                        Text("\(waterAmount, specifier: "%.2f")")
                            .font(.title)
                        Text("ml")
                    }
                }
            }
            .navigationTitle("Juice Calculator")
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()

                    Button("Done") {
                        isFocused = false
                    }
                }
            }
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
        
            isFocused = false
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
            
            isFocused = false
        }) {
            Text("Calculate")
        }
    }
}

#if DEBUG
#Preview {
    SuperJuiceView(typeOfJuice: "Lime")
        .preferredColorScheme(.dark)
}
#endif
