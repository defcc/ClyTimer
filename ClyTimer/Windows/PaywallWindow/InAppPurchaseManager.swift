import StoreKit

class InAppPurchaseManager: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    static let shared = InAppPurchaseManager()
    
    var products: [SKProduct] = []
    var viewController: PaywallViewController?
    
    func fetchProducts() {
        let productIdentifiers: Set<String> = ["XTimerLifetime"]
        let request = SKProductsRequest(productIdentifiers: productIdentifiers)
        request.delegate = self
        request.start()
    }
    
    func purchaseProduct(product: SKProduct) {
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
    
    // MARK: SKProductsRequestDelegate
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        products = response.products
        viewController?.updateUI(products)
    }
    
    // MARK: SKPaymentTransactionObserver
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        print("paymentQueue =>")
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                // Provide content or unlock functionality
                SKPaymentQueue.default().finishTransaction(transaction)
                print("buy ok")
                viewController?.showSuccess(transaction)
            case .failed:
                // Handle failed transaction
                SKPaymentQueue.default().finishTransaction(transaction)
                if let error = transaction.error as? SKError {
                    if error.code == .paymentCancelled {
                        print("Transaction canceled")
                    } else {
                        print("Transaction failed with error: \(error.localizedDescription)")
                    }
                }
                print("buy failed")
                viewController?.showFailed()
            case .restored:
                // Handle restored transaction
                SKPaymentQueue.default().finishTransaction(transaction)
                viewController?.showSuccess(transaction)
            case .deferred:
                // Handle deferred transaction
                break
            case .purchasing:
                // Handle ongoing purchasing
                break
            @unknown default:
                break
            }
        }
    }
    
    func restorePurchases() {
        print("restorePurchases")
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
}

