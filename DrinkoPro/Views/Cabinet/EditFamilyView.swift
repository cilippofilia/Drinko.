//
//  EditFamilyView.swift
//  Drinko
//
//  Created by Filippo Cilia on 04/02/2021.
//

import SwiftUI

struct EditFamilyView: View {
    @EnvironmentObject var dataController: DataController
    @Environment(\.presentationMode) var presentationMode
    
    @State private var showingDeleteConfirm = false
    @State private var name: String
    @State private var detail: String
    @State private var color: String
    
    let colorColumns = [
        GridItem(.adaptive(minimum: 40))
    ]
    
    let family: Family
    
    init(family: Family) {
        self.family = family
        
        _name = State(wrappedValue: family.familyName)
        _detail = State(wrappedValue: family.familyDetail)
        _color = State(wrappedValue: family.familyColor)
    }
    
    var body: some View {
        Form {
            Section(header: Text("Info")) {
                TextField("Category name", text: $name.onChange(update))
                TextField("Category detail", text: $detail.onChange(update))
            }
            
            Section(header: Text("Colors")) {
                LazyVGrid(columns: colorColumns) {
                    ForEach(Family.colors, id: \.self, content: colorPalette)
                }
                .padding(.vertical)
            }
            
            Section(footer: Text("By deleting the category you will be deleting every product inside it.")) {
                Button(action: {
                    update()
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Image(systemName: "checkmark.circle")

                        Text("Save Changes")
                    }
                }
                
                Button(action: {
                    showingDeleteConfirm.toggle()
                }) {
                    HStack {
                        Image(systemName: "trash")

                        Text("Delete Category")
                    }
                    .foregroundColor(Color.red)
                }
            }
        }
        .navigationBarTitle("Edit Category")
        .onDisappear(perform: dataController.save)
        .alert(isPresented: $showingDeleteConfirm) {
            Alert(
                title: Text("Delete category?"),
                message: Text("Are you sure you want to delete this category? You will also delete all the products it contains."),
                primaryButton: .default(Text("Delete"), action: delete),
                secondaryButton: .cancel()
            )
        }
    }
    
    func update() {
        family.name = name
        family.detail = detail
        family.color = color
    }
    
    func delete() {
        dataController.delete(family)
        presentationMode.wrappedValue.dismiss()
    }
    
    func colorPalette(for item: String) -> some View {
        ZStack {
            Color(item)
                .aspectRatio(1, contentMode: .fit)
                .cornerRadius(6)
            
            if item == color {
                Image(systemName: "checkmark.circle")
                    .foregroundColor(.white)
                    .font(.largeTitle)
            }
        }
        .onTapGesture {
            color = item
            update()
        }
    }
}
