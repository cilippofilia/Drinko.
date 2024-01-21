//
//  UserCreationsView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 21/01/2024.
//

import SwiftUI
import TipKit

struct UserCreationsView: View {
    static let userCreationsTag: String? = "User Creations"
    
    @Environment(\.horizontalSizeClass) var sizeClass
    
    @StateObject var viewModel: ViewModel
    
    var favoriteItemTip = CreateCocktailTip()
    
    init(dataController: DataController) {
        let viewModel = ViewModel(dataController: dataController)
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.userCocktails.isEmpty {
                    /// This VStack can be replaced by ContentUnavailableView
                    /// available only from iOS17 onwards
                    VStack {
                        Image(systemName: "testtube.2")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 44)
                        
                        Text("Start adding your cocktail creations by pressing the + above.")
                    }
                    .italic()
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: sizeClass == .compact ? compactScreenWidth : regularScreenWidth)
                    
                } else {
                    userCocktailView
                }
            }
            .navigationTitle("Your Creations")
            .navigationSplitViewStyle(AutomaticNavigationSplitViewStyle())
            .toolbar {
                addCocktailToolbarItem
            }
        }
    }
}

private extension UserCreationsView {
    var addCocktailToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                withAnimation {
                    viewModel.addUserCocktail()
                }
            } label: {
                if UIAccessibility.isVoiceOverRunning {
                    Text("Add Cocktail")
                } else {
                    Label("Add Cocktail", systemImage: "plus")
                }
            }
        }
    }
}

private extension UserCreationsView {
    var userCocktailView: some View {
        List {
            ForEach(viewModel.userCocktails) { cocktail in
                NavigationLink(destination: EmptyView()) {
                    HStack {
                        // replace this with cocktail icons
                        Image(systemName: "person.fill")
                            .imageScale(.large)
                            .foregroundStyle(.secondary)
                            
                        Text(cocktail.userCocktailName)
                        
                        Spacer()
                    }
                }
            }
        }
    }
}

#Preview {
    UserCreationsView(dataController: DataController())
}
