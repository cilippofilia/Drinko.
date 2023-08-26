//
//  PurchaseManager.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 26/08/2023.
//

import Foundation
import StoreKit

@MainActor
class PurchaseManager: ObservableObject {
    @Published private(set) var products: [Product] = []
    @Published private(set) var purchasedProductIDs = Set<String>()

    private let productIDs = ["SmallTip","MediumTip","BigTip","GenerousTip","ExtremelyGenerousTip"]
    private var productsLoaded = false
    private var updates: Task<Void, Never>? = nil

    var hasUnlockedPro: Bool {
        return !self.purchasedProductIDs.isEmpty
    }

    init() {
        updates = observeTransactionUpdates()
    }

    deinit {
        updates?.cancel()
    }
    func loadProducts() async throws {
        guard !self.productsLoaded else { return }
        self.products = try await Product.products(for: productIDs)
        self.productsLoaded = true
    }

    func purchase(_ product: Product) async throws {
        let result = try await product.purchase()

        switch result {
        case let .success(.verified(transaction)):
            // Successful purhcase
            await transaction.finish()
            await self.updatePurchasedProducts()
        case let .success(.unverified(_, error)):
            // Successful purchase but transaction/receipt can't be verified
            // Could be a jailbroken phone
            print(error.localizedDescription)
            break
        case .userCancelled:
            break
        case .pending:
            // Transaction waiting on SCA (Strong Customer Authentication) or
            // approval from Ask to Buy
            break
        @unknown default:
            break
        }
    }

    func updatePurchasedProducts() async {
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else { continue }

            if transaction.revocationDate == nil {
                self.purchasedProductIDs.insert(transaction.productID)
            } else {
                self.purchasedProductIDs.remove(transaction.productID)
            }
        }
    }

    private func observeTransactionUpdates() -> Task<Void, Never> {
        Task(priority: .background) { [unowned self] in
            await self.updatePurchasedProducts()
        }
    }
}
