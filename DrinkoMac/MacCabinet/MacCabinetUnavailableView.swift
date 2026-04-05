//
//  MacCabinetUnavailableView.swift
//  DrinkoMac
//
//  Created by Filippo Cilia on 21/01/2026.
//

import SwiftData
import SwiftUI

struct MacCabinetUnavailableView: View {
    @Environment(\.modelContext) private var modelContext

    @Binding var showAddCategorySheet: Bool

    let action: () -> Void
    @State private var errorTitle: String = "Something went wrong"
    @State private var errorMessage: String = ""
    @State private var showError: Bool = false

    var body: some View {
        ContentUnavailableView(label: {
            Label("Empty Cabinet", systemImage: "cabinet.fill")
        }, description: {
            Text("To start, press 'Add a category' below or the + button at the top of the view.")
        }, actions: {
            Button("Add a category") {
                action()
            }
            .accessibilityHint("Creates a new category.")
        })
        .frame(width: screenWidth)
        .navigationTitle("Cabinet")
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button(action: {
                    action()
                }) {
                    Label("Add category", systemImage: "plus")
                }
                .accessibilityLabel("Add category")
            }
        }
        .sheet(isPresented: $showAddCategorySheet) {
            MacAddCategoryView()
        }
        .alert(isPresented: $showError) {
            Alert(
                title: Text(errorTitle),
                message: Text(errorMessage),
                dismissButton: .cancel(Text("OK"))
            )
        }
    }

    private func addSampleData() {
        do {
            let sampleCategories = Category.mockCategories
            for category in sampleCategories {
                modelContext.insert(category)
            }
            try modelContext.save()
        } catch {
            errorTitle = "Unable to Add Samples"
            errorMessage = "Please try again.\n\nFailed to add sample data: \(error)"
            showError = true
        }
    }
}

#if DEBUG
#Preview {
    MacCabinetUnavailableView(showAddCategorySheet: .constant(true), action: { })
        .drinkoPreviewEnvironment()
}
#endif
