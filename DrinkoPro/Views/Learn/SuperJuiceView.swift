//
//  SuperJuiceView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 03/10/2023.
//

import SwiftUI

#warning("👨‍💻 Finish this View before starting to refactor code")

enum CalculationMode: String, CaseIterable {
    case peels = "By Peels"
    case water = "By Water"
}

struct SuperJuiceView: View {
    @State private var selectedMode = CalculationMode.peels
    @State private var peels = ""
    @State private var water = ""

    @State private var citricAcid: Double = 0
    @State private var malicAcid: Double = 0
    @State private var waterAmount: Double = 0

    var body: some View {
        NavigationView {
            VStack {
                Picker("Calculation Mode", selection: $selectedMode) {
                    ForEach(CalculationMode.allCases, id: \.self) { mode in
                        Text(mode.rawValue)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())

                Form {
                    Section(header: Text(selectedMode == .peels ? "Lime peels (gr)" : "Water (ml)")) {
                        Group {
                            if selectedMode == .peels {
                                TextField("Lime Peels in grams", text: $peels)
                            } else {
                                TextField("Water amount in millilitres", text: $water)
                            }
                        }
                        .keyboardType(.decimalPad)
                    }

                    Section {
                        Button(action: {
                            guard !peels.isEmpty else { return peels = "0" }
                            guard !water.isEmpty else { return peels = "0" }

                            if selectedMode == .peels {
                                citricAcid = 0.66 * Double(peels)!
                                malicAcid = 0.33 * Double(peels)!
                                waterAmount = 16.66 * Double(peels)!
                            }
                        }) {
                            Text("Calculate")
                        }
                    }

                    Section(footer: Text("Remember to add the juice of the peeled fruits used to make superjuice. The final volume will be a bit higher than the water volume displayed.")) {
                        Text("Citric Acid:\n") + Text("\(citricAcid, specifier: "%.2f") gr")
                            .font(.title)

                        Text("Malic Acid:\n") + Text("\(malicAcid, specifier: "%.2f") gr")
                            .font(.title)

                        Text("Water:\n") + Text("\(waterAmount, specifier: "%.2f") ml")
                            .font(.title)
                    }
                }
                .navigationTitle("Juice Calculator")
            }
        }
    }
}

#Preview {
    SuperJuiceView()
        .preferredColorScheme(.dark)
}
