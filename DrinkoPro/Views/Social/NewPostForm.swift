//
//  NewPostForm.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 14/08/2023.
//

import SwiftUI

// MARK: - NewPostForm

struct NewPostForm: View {
    typealias CreateAction = (Post) async throws -> Void

    let createAction: CreateAction

    @State private var post = Post(title: "", content: "", authorName: "")
    @State private var state = FormState.idle

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Title", text: $post.title)
                    TextField("Author Name", text: $post.authorName)
                }

                Section("Content") {
                    TextEditor(text: $post.content)
                        .multilineTextAlignment(.leading)
                }
                
                Button(action: createPost) {
                    if state == .working {
                        ProgressView()
                    } else {
                        Text("Create Post")
                    }
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .foregroundColor(.white)
                .padding()
                .listRowBackground(Color.accentColor)
            }
            .onSubmit(createPost)
            .navigationTitle("New Post")
        }
        .disabled(state == .working)
        .alert("Cannot Create Post", isPresented: $state.isError, actions: {}) {
            Text("Sorry, something went wrong.")
        }
    }

    private func createPost() {
        Task {
            state = .working
            do {
                try await createAction(post)
                dismiss()
            } catch {
                print("[NewPostForm] Cannot create post: \(error)")
                state = .error
            }
        }
    }
}

// MARK: - FormState

private extension NewPostForm {
    enum FormState {
        case idle, working, error

        var isError: Bool {
            get {
                self == .error
            }
            set {
                guard !newValue else { return }
                self = .idle
            }
        }
    }
}

// MARK: - Preview

struct NewPostForm_Previews: PreviewProvider {
    static var previews: some View {
        NewPostForm(createAction: { _ in })
    }
}
