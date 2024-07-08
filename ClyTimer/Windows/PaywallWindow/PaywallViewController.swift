import Foundation
import Cocoa
import StoreKit

class PaywallViewController: NSViewController {
    private var successAlert: NSAlert {
        let alert = NSAlert()
        alert.alertStyle = .informational
        alert.messageText = NSLocalizedString("Success!", comment: "")
        alert.informativeText = NSLocalizedString("Thanks for your support", comment: "")
        alert.addButton(withTitle: NSLocalizedString("Close", comment: ""))
        alert.icon = NSImage(named: "ProSuccessIcon")
        return alert
    }
    
    private var failedAlert: NSAlert {
        let alert = NSAlert()
        alert.alertStyle = .informational
        alert.messageText = NSLocalizedString("Something wrong", comment: "")
        alert.informativeText = NSLocalizedString("You could try again later", comment: "")
        alert.addButton(withTitle: NSLocalizedString("Close", comment: ""))
        alert.icon = NSImage(named: "NSCaution")
        return alert
    }
    
    private var loadingErrorAlert: NSAlert {
        let alert = NSAlert()
        alert.alertStyle = .informational
        alert.messageText = NSLocalizedString("Something wrong", comment: "")
        alert.informativeText = NSLocalizedString("Could not fetch IAP items, please try later", comment: "")
        alert.addButton(withTitle: NSLocalizedString("Close", comment: ""))
        alert.icon = NSImage(named: "NSCaution")
        return alert
    }
    @IBOutlet weak var loading: NSProgressIndicator!
    @IBOutlet weak var priceLabel: NSTextField!
    @IBOutlet weak var overlay: NSView!
    
    var isLoading = false
    
    let purchaseManager = InAppPurchaseManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        purchaseManager.viewController = self
        overlay.wantsLayer = true
        overlay.layer?.backgroundColor = NSColor.black.withAlphaComponent(0.2).cgColor
        SKPaymentQueue.default().add(purchaseManager)
    }
    
    override func viewDidAppear() {
        self.showLoading()
        purchaseManager.fetchProducts()
    }
    
    func showLoading() {
        DispatchQueue.main.async {
            self.isLoading = true
            self.loading.isHidden = false
            self.loading.startAnimation(nil)
            self.overlay.isHidden = false
        }
    }
    
    func hideLoading() {
        DispatchQueue.main.async {
            self.isLoading = false
            self.loading.isHidden = true
            self.loading.stopAnimation(nil)
            self.overlay.isHidden = true
        }
    }
    
    func updateUI(_ products: [SKProduct]) {
        if products.isEmpty {
            hideLoading()
            DispatchQueue.main.async {
                self.loadingErrorAlert.runModal()
            }
            return
        }
        let product = products[0]
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        
        numberFormatter.locale = product.priceLocale
        
        if let formattedPrice = numberFormatter.string(from: product.price) {
            DispatchQueue.main.async {
                self.priceLabel.stringValue = formattedPrice
                self.hideLoading()
            }
        } else {
            print("Formatting failed")
        }
    }
    
    func showSuccess(_ transaction: SKPaymentTransaction) {
        DataModel.shared.updateSettingBatch(updateDictionary: [
            "isLTD": true,
            "isVip": true,
            "vipStartAt": transaction.transactionDate
        ])
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .proSuccessEvt, object: nil)
            self.successAlert.runModal()
        }
    }
    
    func showFailed() {
        hideLoading()
        DispatchQueue.main.async {
            self.failedAlert.runModal()
        }
    }
    @IBAction func purchaseButtonTapped(_ sender: NSButton) {
        if isLoading {
            return
        }
        showLoading()
        if let product = purchaseManager.products.first {
            purchaseManager.purchaseProduct(product: product)
        }
    }
    
    @IBAction func restoreButtonTapped(_ sender: NSButton) {
        if isLoading {
            return
        }
        showLoading()
        purchaseManager.restorePurchases()
    }
}

