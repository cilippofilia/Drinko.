//
//  ProcedureView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 04/01/2024.
//

import SwiftUI

struct ProcedureView: View {
    let procedure: String
    
    var body: some View {
        VStack {
            Text("Procedure:")
        }
    }
}

#Preview {
    ProcedureView(procedure: "Testing procedure")
}
