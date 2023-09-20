//
//  DrinkoProApp.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 31/05/2023.
//

import SwiftUI

@main
struct DrinkoProApp: App {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @StateObject var dataController: DataController
    @StateObject var purchaseManager: PurchaseManager

    init() {
        let dataController = DataController()
        let purchaseManager = PurchaseManager()
        _dataController = StateObject(wrappedValue: dataController)
        _purchaseManager = StateObject(wrappedValue: purchaseManager)
    }
    
    var body: some Scene {
        WindowGroup {
            if horizontalSizeClass == .compact {
                SplashScreenView()
                    .environment(\.managedObjectContext, dataController.container.viewContext)
                    .environmentObject(dataController)
                    .environmentObject(purchaseManager)
                    .task {
                        await purchaseManager.updatePurchasedProducts()
                    }
                    // Automatically save when we detect that we are
                    // no longer the foreground app. Use this rather than
                    // scene phase so we can port to macOS, where scene
                    // phase won't detect our app losing focus.
                    .onReceive(
                        NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification),
                        perform: save
                    )
            } else {
                SplashScreenView()
                    .environment(\.managedObjectContext, dataController.container.viewContext)
                    .environmentObject(dataController)
                    .environmentObject(purchaseManager)
                    .task {
                        await purchaseManager.updatePurchasedProducts()
                    }
                    // Automatically save when we detect that we are
                    // no longer the foreground app. Use this rather than
                    // scene phase so we can port to macOS, where scene
                    // phase won't detect our app losing focus.
                    .onReceive(
                        NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification),
                        perform: save
                    )
            }
        }
    }
    
    func save(_ note: Notification) {
        dataController.save()
    }
}
