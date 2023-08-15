//
//  PostRowView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 12/08/2023.
//

import SwiftUI

struct PostRow: View {
    @ObservedObject var viewModel: PostRowViewModel

    @State private var showConfirmationDialog = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(viewModel.authorName)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Spacer()

                Text(viewModel.timestamp.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
            }
            .foregroundColor(.gray)

            Text(viewModel.title)
                .font(.title3)
                .fontWeight(.semibold)

            Text(viewModel.content)

            HStack {
                LikeButton(isLiked: viewModel.isLiked, action: {
                    viewModel.likePost()
                })

                Spacer()

                Button(role: .destructive, action: {
                    showConfirmationDialog = true

                }) {
                    Label("Delete", systemImage: "trash")
                }
                .labelStyle(.iconOnly)
                .buttonStyle(.borderless)
            }
        }
        .padding(.vertical)
        .confirmationDialog("Are you sure you want to delete this post?",
                            isPresented: $showConfirmationDialog,
                            titleVisibility: .visible) {
            Button("Delete",
                   role: .destructive,
                   action:  {
                viewModel.deletePost()
            })
        }
        .alert("Cannot Delete Post", error: $viewModel.error)
    }
}

private extension PostRow {
    struct LikeButton: View {
        let isLiked: Bool
        let action: () -> Void

        var body: some View {
            Button(action: action) {
                if isLiked {
                    Label("Remove like from post", systemImage: "heart.fill")
                } else {
                    Label("Like the post", systemImage: "heart")
                }
            }
            .foregroundColor(isLiked ? .red : .gray)
            .animation(.default, value: isLiked)
            .labelStyle(.iconOnly)
            .buttonStyle(.borderless)
        }
    }
}

#if DEBUG
struct PostRow_Previews: PreviewProvider {
    static var previews: some View {
        List {
            PostRow(viewModel: PostRowViewModel(post: Post.testPost,
                                                deleteAction: {},
                                                likeAction: {}))
        }
    }
}
#endif
