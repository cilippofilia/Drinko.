//
//  StoreManager.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 26/08/2023.
//

import Foundation
import StoreKit

@Observable
class StoreManager {
    private let productIds = [
        "drinko_premium_lifetime",
        "DrinkoPremiumYearly",
        "DrinkoPremiumMonthly",
        "SmallTip",
        "MediumTip",
        "BigTip",
        "GenerousTip",
        "ExtremelyGenerousTip"
    ]
    
    var products: [Product] = []
    
    var hasUnlockedPro: Bool {
        return self.purchasedProductIds.contains(where: { $0 == "drinko_premium_lifetime" })
        || self.purchasedProductIds.contains(where: { $0 == "DrinkoPremiumYearly" })
        || self.purchasedProductIds.contains(where: { $0 == "DrinkoPremiumMonthly" })
    }

    private var productLoaded = false
    private var updates: Task<Void, Never>? = nil
    
    private(set) var purchasedProductIds = Set<String>()

    init() {
        updates = observeTransactionUpdates()
    }

    deinit {
        updates?.cancel()
    }
    
    func loadTipsProducts() async throws {
        guard !self.productLoaded else { return }
        
        self.products = try await Product.products(for: productIds)
        self.productLoaded = true
    }

    func purchase(_ product: Product) async throws {
        let result = try await product.purchase()
        
        switch result {
        case let .success(.verified(transaction)):
            // Successful purchase
            await transaction.finish()
            await self.updatePurchasedProducts()

        case let .success(.unverified(_, error)):
            // Successful purchase but transaction/receipt can't be verified
            // Could be a jailbroken phone
            print("Error: \(error.localizedDescription)")
            break
            
        case .pending:
            // Transaction waiting on SCA (Strong Customer Authentication) or
            // approval from Ask to Buy
            break
            
        case .userCancelled:
            break
            
        @unknown default: // used in case apple implements more cases in future release
            break
        }
    }
    
    func updatePurchasedProducts() async {
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else { continue }
            
            if transaction.revocationDate == nil {
                self.purchasedProductIds.insert(transaction.productID)
            } else {
                self.purchasedProductIds.remove(transaction.productID)
            }
        }
    }
    
    private func observeTransactionUpdates() -> Task<Void, Never> {
        Task(priority: .background) { [unowned self] in
//            for await verificationResult in Transaction.updates {
            for await _ in Transaction.updates {
                // Using verificationResult directly would be better
                // but this way works for this tutorial
                await self.updatePurchasedProducts()
            }
        }
    }
}

// MARK: HELPER METHODS
extension StoreManager {
    func purchaseProduct(_ product: Product) {
        Task {
            do {
                try await purchase(product)
            } catch {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func restoreSubscription() {
        Task {
            do {
                try await AppStore.sync()
            } catch {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func returnSubs(_ products: [Product]) -> [Product] {
        products.filter({ $0.type != .consumable })
    }
    
    func returnTips(_ products: [Product]) -> [Product] {
        products.filter({ $0.type == .consumable })
    }

    func sortByPrice(_ products: [Product]) -> [Product] {
        products.sorted(by: { return $0.price < $1.price })
    }
}
