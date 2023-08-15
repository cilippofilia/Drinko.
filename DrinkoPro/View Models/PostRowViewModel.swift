//
//  PostRowViewModel.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 15/08/2023.
//

import Foundation

@MainActor
@dynamicMemberLookup
class PostRowViewModel: ObservableObject {
    typealias Action = () async throws -> Void
    
    subscript<T>(dynamicMember keyPath: KeyPath<Post, T>) -> T {
        post[keyPath: keyPath]
    }

    @Published var post: Post
    @Published var error: Error?

    private let deleteAction: Action
    private let likeAction: Action

    init(post: Post, deleteAction: @escaping Action, likeAction: @escaping Action) {
        self.post = post
        self.deleteAction = deleteAction
        self.likeAction = likeAction
    }

    func deletePost() {
        withErrorHandlingTask(perform: deleteAction)
    }

    func likePost() {
        withErrorHandlingTask(perform: likeAction)
    }

    private func withErrorHandlingTask(perform action: @escaping Action) {
        Task {
            do {
                try await action()
            } catch {
                print("[PostRowViewModel] Error: \(error)")
                self.error = error
            }
        }
    }
}
