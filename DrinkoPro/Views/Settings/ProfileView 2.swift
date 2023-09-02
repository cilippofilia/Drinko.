//
//  ProfileView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 15/08/2023.
//

import FirebaseAuth
import SwiftUI

struct ProfileView: View {
    var body: some View {
        Button("Sign Out", action: {
            try! Auth.auth().signOut()
        })
    }
}

#if DEBUG
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
#endif
