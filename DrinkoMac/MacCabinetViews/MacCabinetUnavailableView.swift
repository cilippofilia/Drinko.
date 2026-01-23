//
//  MacCabinetUnavailableView.swift
//  DrinkoMac
//
//  Created by Filippo Cilia on 21/01/2026.
//

import SwiftUI

struct MacCabinetUnavailableView: View {
    @Binding var showAddCategorySheet: Bool

    let action: () -> Void
    let testAction: () -> Void

    var body: some View {
        ContentUnavailableView(label: {
            Label("Empty Cabinet", systemImage: "cabinet.fill")
        }, description: {
            Text("To start, press 'Add a category' below or the + button at the top of the view.")
        }, actions: {
            Button("Add a category") {
                action()
            }

            Button("Add sample data") {
                testAction()
            }
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
            }
        }
        .sheet(isPresented: $showAddCategorySheet) {
            AddCategoryView()
        }
    }
}

#Preview {
    MacCabinetUnavailableView(showAddCategorySheet: .constant(true), action: { }, testAction: { })
}
