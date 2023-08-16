//
//  PostsViewModel.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 14/08/2023.
//

import Foundation

@MainActor
class PostsViewModel: ObservableObject {
    enum Filter {
        case all, liked
    }

    @Published var posts: Loadable<[Post]> = .loading

    private let postsRepository: PostsRepositoryProtocol
    private let filter: Filter

    var title: String {
        switch filter {
        case .all:
            return "Posts"
        case .liked:
            return "Liked"
        }
    }

    init(filter: Filter = .all, postsRepository: PostsRepositoryProtocol = PostsRepository()) {
        self.filter = filter
        self.postsRepository = postsRepository
    }

    func fetchPosts() {
        Task {
            do {
                posts = .loaded(try await postsRepository.fetchPosts(matching: filter))
            } catch {
                print("[PostsViewModel] Cannot fetch posts: \(error)")
                posts = .error(error)
            }
        }
    }

    func makeCreateAction() -> NewPostForm.CreateAction {
        return { [weak self] post in
            try await self?.postsRepository.create(post)
            self?.posts.value?.insert(post, at: 0)
        }
    }

    func makePostRowViewModel(for post: Post) -> PostRowViewModel {
        return PostRowViewModel(post: post,
                                deleteAction: { [weak self] in
            try await self?.postsRepository.delete(post)
            self?.posts.value?.removeAll { $0 == post }
        },
                                likeAction: { [weak self] in
            let newValue = !post.isLiked
            try await newValue ? self?.postsRepository.like(post) : self?.postsRepository.unlike(post)
            guard let i = self?.posts.value?.firstIndex(of: post) else { return }
            self?.posts.value?[i].isLiked = newValue
        })
    }
}

private extension PostsRepositoryProtocol {
    func fetchPosts(matching filter: PostsViewModel.Filter) async throws -> [Post] {
        switch filter {
        case .all:
            return try await fetchAllPosts()
        case .liked:
            return try await fetchLikedPosts()
        }
    }
}
