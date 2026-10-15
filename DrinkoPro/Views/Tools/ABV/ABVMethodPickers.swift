//
//  ABVMethodPickers.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 26/09/2026.
//

import SwiftUI

/// Lets the person choose the mixing method and serving used for an ABV calculation.
struct ABVMethodPickers: View {
    @Binding var method: MixingMethod
    @Binding var serving: Serving

    var body: some View {
        VStack {
            LabeledContent("Pick the method") {
                Picker("Pick the method", selection: $method) {
                    ForEach(MixingMethod.allCases) { method in
                        Text(method.title).tag(method)
                    }
                }
                .labelsHidden()
            }

            LabeledContent("Pick the serving") {
                Picker("Pick the serving", selection: $serving) {
                    ForEach(Serving.allCases) { serving in
                        Text(serving.title).tag(serving)
                    }
                }
                .labelsHidden()
            }
        }
    }
}

#if DEBUG
#Preview {
    @Previewable @State var method: MixingMethod = .built
    @Previewable @State var serving: Serving = .up

    ABVMethodPickers(method: $method, serving: $serving)
}
#endif
