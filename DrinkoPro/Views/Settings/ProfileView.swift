//
//  ProfileView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 20/08/2023.
//

import SwiftUI

struct ProfileView: View {
    @StateObject var viewModel: ProfileViewModel

    var body: some View {
        ScrollView {
            VStack {
                ProfileImage(url: viewModel.imageURL)
                    .frame(width: 200, height: 200)
                    .padding(.top)

                Text(viewModel.name)
                    .font(.title2)
                    .bold()
                    .padding()

                ImagePickerButton(imageURL: $viewModel.imageURL) {
                    Label("Choose Image", systemImage: "photo.fill")
                }
                .padding(.bottom)

                DrinkoButtonView(title: "Sign Out",
                                 icon: "figure.walk",
                                 background: .red,
                                 foreground: .white) {
                    viewModel.signOut()

                }
                .padding(.vertical)
                .frame(width: screenWidthPlusMargins)
            }
            .navigationTitle("Profile")
        }
        .alert("Error", error: $viewModel.error)
        .disabled(viewModel.isWorking)
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        TabView {
            ProfileView(viewModel: ProfileViewModel(user: User.testUser, authService: AuthService()))
        }
    }
}
