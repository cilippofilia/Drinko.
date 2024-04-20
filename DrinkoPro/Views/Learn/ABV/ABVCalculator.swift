//
//  ABVCalculator.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 29/11/2023.
//

import SwiftUI

enum Serving: String, CaseIterable {
    case up = "Up"
    case rocks = "On the rocks"
    case crushed = "Crushed Ice"
}

enum Method: String, CaseIterable {
    case built = "Built in the glass"
    case shake = "Shaken"
    case stir = "Stirred"
}

struct Bottle {
    var id = UUID()
    var name: String = ""
    var amount: Double = 0.0
    var abv: Double = 0.0
}

struct ABVCalculator: View {
    @State private var bottles: [Bottle] = [Bottle(name: "", amount: 0.0, abv: 0.0)]
    @State var numbersOfIngredients = 1
    
    @State private var selectedServing: Serving = .up
    @State private var selectedMethod: Method = .built
    @State private var result: Double = 0
    
    var body: some View {
            ScrollView {
                ForEach(bottles.indices, id:\.self) { index in
                    VStack(spacing: 20) {
                        HStack {
                            TextField("What is the ingredient?", text: $bottles[index].name)
                                .keyboardType(/*@START_MENU_TOKEN@*/.default/*@END_MENU_TOKEN@*/)
                            
                            Button(action: {
                                removeIngredient(at: index)
                            }) {
                                Label("Delete", systemImage: "xmark.circle")
                                    .labelStyle(.iconOnly)
                                    .foregroundColor(bottles.count > 1 ? .secondary : .clear)
                            }
                        }
                        
                        HStack(spacing: 20) {
                            HStack {
                                TextField("Amount?", value: $bottles[index].amount, formatter: NumberFormatter())
                                    .keyboardType(.decimalPad)
                                
                                Text("ml")
                            }
                            
                            HStack {
                                TextField("ABV?", value: $bottles[index].abv, formatter: NumberFormatter())
                                    .keyboardType(.decimalPad)
                                Text("%")
                            }
                        }
                        Divider()
                    }
                    .padding()
                }
                                
                Button(action: {
                    bottles.append(Bottle(name: "", amount: 0.0, abv: 0.0))
                    numbersOfIngredients += 1
                }) {
                    Label("Add ingredient", systemImage: "plus")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                
                Spacer(minLength: 30)
                
                pickers
                
                DrinkoButtonView(title: "Calculate", icon: "calculator") {
                    result = calculateABV()
                }
                .frame(width: 200)
                .padding()
                
                VStack {
                    Text("ABV")
                        .font(.headline)
                    
                    Spacer()
                    
                    Text("\(result, specifier: "%.2f") %")
                        .font(.title)
                        .bold()
                }
                
                Text("Use 'Built in the glass' and 'served up' to calculate the ABV of your own batches. Those two combined will not add any dilution to the drink.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(.vertical)
                
                Spacer(minLength: 50)
            }
            .navigationTitle("ABV Calculator")
            .padding(.horizontal)
            .scrollIndicators(.hidden, axes: .vertical)
            .scrollBounceBehavior(.basedOnSize)
    }
        
    func calculateABV() -> Double {
        var totalVolume = 0.0
        var totalAlcohol = 0.0
        let dilutionFactor: Double

        for product in bottles {
            totalVolume += product.amount
            totalAlcohol += (product.amount * product.abv / 100)
        }
        
        switch (selectedServing, selectedMethod) {
            case (.up, .stir):
                dilutionFactor = 0.25
            case (.up, .shake):
                dilutionFactor = 0.3
            case (.rocks, .stir):
                dilutionFactor = 0.3
            case (.rocks, .shake):
                dilutionFactor = 0.35
            case (.crushed, .shake):
                dilutionFactor = 0.4
            default:
                dilutionFactor = 0.0
            }
            
            let dilutedVolume = totalVolume * (1 + dilutionFactor)
            let overallABV = totalAlcohol / dilutedVolume * 100

            return overallABV
    }
    
    private func removeIngredient(at index: Int) {
        bottles.remove(at: index)
    }
}

private extension ABVCalculator {
    var pickers: some View {
        VStack {
            HStack {
                Text("Pick the method")

                Spacer()
                
                Picker("", selection: $selectedMethod) {
                    ForEach(Method.allCases, id:\.self) { method in
                        Text(method.rawValue)
                    }
                }
            }

            HStack {
                Text("Pick the serving")

                Spacer()
                
                Picker("", selection: $selectedServing) {
                    ForEach(Serving.allCases, id:\.self) { serve in
                        Text(serve.rawValue)
                    }
                }
            }
        }
    }
}

#Preview {
    ABVCalculator()
}
