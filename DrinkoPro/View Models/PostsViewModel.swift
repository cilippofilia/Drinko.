//
//  PostsViewModel.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 14/08/2023.
//

import Foundation

@MainActor
class PostsViewModel: ObservableObject {
    @Published var posts: Loadable<[Post]> = .loading

    private let postsRepository: PostsRepositoryProtocol

    init(postsRepository: PostsRepositoryProtocol = PostsRepository()) {
        self.postsRepository = postsRepository
    }

    func fetchPosts() {
        Task {
            do {
                posts = .loaded(try await postsRepository.fetchPosts())
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
