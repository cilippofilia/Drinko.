//
//  ProcedureView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 04/01/2024.
//

import SwiftUI

struct ProcedureView: View {
    let cocktail: Cocktail
    let procedure: Procedure
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading) {
                Text("Procedure")
                    .font(.title.bold())
                    .padding(.vertical)
                    .padding(.top)

                ForEach(procedure.procedure) { steps in
                    VStack(alignment: .leading, spacing: 10) {
                        Text(steps.step)
                            .bold()
                        Text(steps.text)
                    }
                    .padding(.vertical, 5)
                    .multilineTextAlignment(.leading)
                }
            }
            .frame(width: compactScreenWidth)
        }
    }
}

#Preview {
    ProcedureView(cocktail: .example, procedure: .example)
}
