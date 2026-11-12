//
//  SettingsContactsView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 20/09/2023.
//

import AboutSection
import SwiftUI

struct SettingsContactsView: View {
    var body: some View {
        Section(header: Text("Contacts")) {
            ContactRow(info: drinkoAppInfo)
            SuggestFeatureRow(info: drinkoAppInfo)
            RateRow(info: drinkoAppInfo)
        }
    }
}

#if DEBUG
#Preview {
    Form {
        SettingsContactsView()
    }
}
#endif
