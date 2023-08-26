//
//  UnlockView.swift
//  Drinko
//
//  Created by Filippo Cilia on 24/04/2021.
//

import StoreKit
import SwiftUI

struct UnlockView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var unlockManager: UnlockManager

    var body: some View {
        VStack {
            switch unlockManager.requestState {
            case .loaded(let product):
                ProductView(product: product)
            case .failed(_):
                Text("Sorry, there was an error loading the store. Please try again later.")
            case .loading:
                ProgressView("Loading...")
            case .purchased:
                Text("Thank you!")
            case.deferred:
                Text("Thank you! Your request is pending approval, but you can carry on using the app in the meantime.")
            }

            Button("Dismiss") {
                dismiss()
            }
            .padding()
        }
        .padding()
        .onReceive(unlockManager.$requestState) { value in
            if case .purchased = value {
                dismiss()
            }
        }
    }
}
