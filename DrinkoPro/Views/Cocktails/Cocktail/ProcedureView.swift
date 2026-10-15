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
        VStack(alignment: .leading, spacing: detailCardGroupSpacing) {
            ForEach(procedure.procedure) { step in
                VStack(alignment: .leading) {
                    Text(step.step)
                        .bold()

                    Text(step.text)
                }
                .multilineTextAlignment(.leading)

                if step.id != procedure.procedure.last?.id {
                    Divider()
                }
            }
        }
    }
}

#if DEBUG
#Preview {
    ProcedureView(cocktail: .example, procedure: .example)
}
#endif
