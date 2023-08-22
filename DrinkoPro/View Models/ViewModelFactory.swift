//
//  ViewModelFactory.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 16/08/2023.
//

import Foundation

@MainActor
class ViewModelFactory: ObservableObject {
    private let user: User
    private let authService: AuthService

    init(user: User, authService: AuthService) {
        self.user = user
        self.authService = authService
    }

    func makePostsViewModel(filter: PostsViewModel.Filter = .all) -> PostsViewModel {
        return PostsViewModel(filter: filter, postsRepository: PostsRepository(user: user))
    }

    func makeProfileViewModel() -> ProfileViewModel {
        return ProfileViewModel(user: user, authService: authService)
    }
}

#if DEBUG
extension ViewModelFactory {
    static let preview = ViewModelFactory(user: User.testUser, authService: AuthService())
}
#endif
