//
//  UnlockManager.swift
//  Drinko
//
//  Created by Filippo Cilia on 22/04/2021.
//

//import Combine
//import StoreKit
//
//class UnlockManager: NSObject, ObservableObject, SKPaymentTransactionObserver, SKProductsRequestDelegate {
//    enum RequestState {
//        case loading
//        case loaded(SKProduct)
//        case failed(Error?)
//        case purchased
//        case deferred
//    }
//
//    private enum StoreError: Error {
//        case invalidIdentifiers, missingProduct
//    }
//
//    @Published var requestState = RequestState.loading
//
//    private let dataController: DataController
//    private let request: SKProductsRequest
//    private var loadedProducts = [SKProduct]()
//
//    init(dataController: DataController) {
//        // Store the data controller we were sent.
//        self.dataController = dataController
//
//        // Prepare to look for our unlock products.
//        let productIDs = Set(["CabinetPlus"])
//        
//        request = SKProductsRequest(productIdentifiers: productIDs)
//
//        // This is required because we inherit from NSObject.
//        super.init()
//
//        // Start watching the payment queue.
//        SKPaymentQueue.default().add(self)
//
//        guard dataController.plusVersionUnlocked == false else { return }
//
//        // Set ourselves up to be notified when the product request completes.
//        request.delegate = self
//
//        // Start the request
//        request.start()
//    }
//
//    deinit {
//        SKPaymentQueue.default().remove(self)
//    }
//
//    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
//        DispatchQueue.main.async { [self] in
//            for transaction in transactions {
//                switch transaction.transactionState {
//                case .purchased, .restored:
//                    self.dataController.plusVersionUnlocked = true
//                    self.requestState = .purchased
//                    queue.finishTransaction(transaction)
//                    
//                case .failed:
//                    if let product = loadedProducts.first {
//                        self.requestState = .loaded(product)
//                    } else {
//                        self.requestState = .failed(transaction.error)
//                    }
//
//                    queue.finishTransaction(transaction)
//
//                case .deferred:
//                    self.requestState = .deferred
//
//                default:
//                    break
//                }
//            }
//        }
//    }
//
//    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
//        DispatchQueue.main.async {
////            Store the returned products for later, if we need them.
//            self.loadedProducts = response.products
//
//            guard let plus = self.loadedProducts.first else {
//                self.requestState = .failed(StoreError.missingProduct)
//                return
//            }
//
//            if response.invalidProductIdentifiers.isEmpty == false {
//                print("ALERT: Received invalid product identifiers: \(response.invalidProductIdentifiers)")
//                self.requestState = .failed(StoreError.invalidIdentifiers)
//                return
//            }
//
//            self.requestState = .loaded(plus)
//        }
//    }
//
//    func buy(product: SKProduct) {
//        let payment = SKPayment(product: product)
//        SKPaymentQueue.default().add(payment)
//    }
//
//    func restore() {
//        SKPaymentQueue.default().restoreCompletedTransactions()
//    }
//
//    var canMakePayments: Bool {
//        SKPaymentQueue.canMakePayments()
//    }
//}
