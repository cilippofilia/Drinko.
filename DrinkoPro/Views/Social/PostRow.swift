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

    @State private var isCollapsed = false
    @State private var lineLimit = 3

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                AuthorView(author: viewModel.author)
                
                Spacer()

                Text(viewModel.timestamp.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
            }
            .foregroundColor(.gray)

            if let imageURL = viewModel.imageURL {
                PostImage(url: imageURL)
            }

            Text(viewModel.title)
                .font(.title3)
                .fontWeight(.semibold)

            Text(viewModel.content)
                .lineLimit(isCollapsed ? nil : lineLimit)
                .animation(.default, value: isCollapsed)

            if viewModel.content.numberOfLines > lineLimit || viewModel.content.count > 150 {
                Button(isCollapsed ? "show less" : "show more") {
                    isCollapsed.toggle()
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }

            HStack {
                LikeButton(isLiked: viewModel.isFavorite, action: {
                    viewModel.favoritePost()
                })

                Spacer()
                
                if viewModel.canDeletePost {
                    Button(role: .destructive, action: {
                        showConfirmationDialog = true
                    }) {
                        Label("Delete", systemImage: "trash")
                    }
                    .labelStyle(.iconOnly)
                    .buttonStyle(.borderless)
                }
            }
        }
        .padding()
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
            HStack {
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
}

private extension PostRow {
    struct AuthorView: View {
        @EnvironmentObject private var factory: ViewModelFactory

        let author: User

        var body: some View {
            NavigationLink {
                PostsList(viewModel: factory.makePostsViewModel(filter: .author(author)))
            } label: {
                Text(author.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
        }
    }
}

private extension PostRow {
    struct PostImage: View {
        let url: URL

        var body: some View {
            AsyncImage(url: url) { image in
                image
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            } placeholder: {
                Color.clear
            }
        }
    }
}

#if DEBUG
struct PostRow_Previews: PreviewProvider {
    static var previews: some View {
        PostRow(viewModel: PostRowViewModel(post: Post.testPost,
                                            deleteAction: {},
                                            favoriteAction: {}))
        .previewLayout(.sizeThatFits)
    }
}
#endif
