//
//  NewPostForm.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 14/08/2023.
//

import SwiftUI

// MARK: - NewPostForm

struct NewPostForm: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject var viewModel: FormViewModel<Post>

    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Title", text: $viewModel.title)
                }

                Section("Content") {
                    TextEditor(text: $viewModel.content)
                        .multilineTextAlignment(.leading)
                }

                Button(action: viewModel.submit) {
                    if viewModel.isWorking {
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
            .onSubmit(viewModel.submit)
            .navigationTitle("New Post")
        }
        .disabled(viewModel.isWorking)
        .alert("Cannot Create Post", error: $viewModel.error)
        .onChange(of: viewModel.isWorking) { isWorking in
            guard !isWorking, viewModel.error == nil else { return }
            dismiss()
        }    }
}

// MARK: - Preview

struct NewPostForm_Previews: PreviewProvider {
    static var previews: some View {
        NewPostForm(viewModel: FormViewModel(initialValue: Post.testPost, action: { _ in }))
    }
}
