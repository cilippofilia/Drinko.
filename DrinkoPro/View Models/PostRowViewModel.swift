//
//  PostRowViewModel.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 15/08/2023.
//

import FirebaseFirestore
import FirebaseFirestoreSwift
import Foundation

@MainActor
@dynamicMemberLookup
class PostRowViewModel: ObservableObject {
    typealias Action = () async throws -> Void

    @Published var post: Post
    @Published var error: Error?

    var canDeletePost: Bool { deleteAction != nil }

    subscript<T>(dynamicMember keyPath: KeyPath<Post, T>) -> T {
        post[keyPath: keyPath]
    }

    private let deleteAction: Action?
    private let favoriteAction: Action

    init(post: Post, deleteAction: Action?, favoriteAction: @escaping Action) {
        self.post = post
        self.deleteAction = deleteAction
        self.favoriteAction = favoriteAction
    }

    func deletePost() {
        guard let deleteAction = deleteAction else {
            preconditionFailure("Cannot delete post: no delete action provided")
        }
        withErrorHandlingTask(perform: deleteAction)
    }

    func favoritePost() {
        withErrorHandlingTask(perform: favoriteAction)
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
