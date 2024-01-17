//
//  ProcedureView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 04/01/2024.
//

import SwiftUI

struct ProcedureView: View {
    @Environment(\.horizontalSizeClass) var sizeClass
    
    var cocktail: Cocktail
    var procedure: Procedure
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading) {
                Text("Procedure")
                    .font(sizeClass == .compact ? .title3.bold() : .title.bold())

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
                .lineSpacing(sizeClass == .compact ? 5 : 10)
            }
        }
    }
}

#if DEBUG
#Preview {
    ProcedureView(cocktail: .example, procedure: .example)
}
#endif
