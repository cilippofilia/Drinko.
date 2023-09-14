//
//  ProfileViewModel.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 20/08/2023.
//

import Foundation

@MainActor
class ProfileViewModel: ObservableObject, StateManager {
    @Published var name: String
    @Published var error: Error?
    @Published var isWorking = false
    @Published var email: String

    private let authService: AuthService

    init(user: User, authService: AuthService) {
        self.name = user.name
        self.email = user.email
        self.authService = authService
    }

    func signOut() {
        withStateManagingTask(perform: authService.signOut)
    }

    func deleteAccount() async throws {
        try await withStateManagingTask(perform: authService.delete)
    }
}
