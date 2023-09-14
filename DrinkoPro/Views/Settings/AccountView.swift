//
//  AccountView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 06/09/2023.
//

import FirebaseAuth
import SwiftUI

struct AccountView: View {
    @StateObject var viewModel: ProfileViewModel
    @State private var showingDeleteConfirm = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Name:")
                Text(viewModel.name)
            }
            .padding(.top)

            HStack {
                Text("Email:")
                Text(viewModel.email)
            }
            .padding(.vertical)

            Spacer()

            Button(role: .destructive) {
                showingDeleteConfirm.toggle()
            } label: {
                Label("Delete Account", systemImage: "trash")
            }
            .padding(.vertical)

            DrinkoButtonView(title: "Sign Out",
                             icon: "figure.walk",
                             background: .red) {
                try! Auth.auth().signOut()
            }
            .padding(.bottom)
        }
        .navigationTitle("Account")
        .frame(width: screenWidthPlusMargins, alignment: .leading)
        .alert(isPresented: $showingDeleteConfirm) {
            Alert(
                title: Text("Delete account?"),
                message: Text("Are you sure you want to delete your account? This action is not reversible."),
                primaryButton: .destructive(Text("Delete"), action: {
                    Task {
                        do {
                            try await viewModel.deleteAccount()
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                }),
                secondaryButton: .cancel()
            )
        }
    }
}

struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        TabView {
            NavigationView {
                AccountView(viewModel: ProfileViewModel(user: .testUser, authService: AuthService()))
            }
        }
    }
}
