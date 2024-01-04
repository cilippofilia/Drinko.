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
            VStack {
                Text("Procedure")
                    .font(.title.bold())
                    .padding(.vertical)
                    .padding(.top)

                VStack(alignment: .leading) {
                    ForEach(procedure.procedure) { steps in
                        Text(steps.step)
                            .bold()
                        
                        Text(steps.text)
                        
                        Divider()
                    }
                    .multilineTextAlignment(.leading)
                    .padding(.vertical, 5)
                }
            }
            .frame(width: compactScreenWidth)
        }
    }
}

#Preview {
    ProcedureView(cocktail: .example, procedure: .example)
}
