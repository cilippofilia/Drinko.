//
//  NewPostForm.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 14/08/2023.
//

import SwiftUI

struct NewPostForm: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject var viewModel: FormViewModel<Post>
    @FocusState var isInputActive: Bool

    var body: some View {
        NavigationView {
            Form {
                Section("Title") {
                    TextField("Title", text: $viewModel.title)
                }

                Section("Image") {
                    AsyncImage(url: viewModel.imageURL) { image in
                        image
                            .resizable()
                            .scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    } placeholder: { }

                    ImagePickerButton(imageURL: $viewModel.imageURL) {
                        Label("Choose Image", systemImage: "photo.fill")
                    }
                }

                Section("Content") {
                    TextEditor(text: $viewModel.content)
                        .multilineTextAlignment(.leading)
                        .frame(minHeight: 200, maxHeight: 400)
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
                .padding(8)
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
        }
    }
}

struct NewPostForm_Previews: PreviewProvider {
    static var previews: some View {
        NewPostForm(viewModel: FormViewModel(initialValue: Post.testPost, action: { _ in }))
    }
}
