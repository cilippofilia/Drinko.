//
//  ProcedureView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 04/01/2024.
//

import SwiftUI

struct ProcedureView: View {
    var cocktail: Cocktail
    var procedure: Procedure

    var body: some View {
        VStack(alignment: .leading) {
            Text("Procedure")
                .font(.title3.bold())

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
    }
}

#if DEBUG
#Preview {
    ProcedureView(cocktail: .example, procedure: .example)
}
#endif
