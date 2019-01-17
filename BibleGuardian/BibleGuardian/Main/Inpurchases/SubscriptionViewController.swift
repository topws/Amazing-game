//
//  SubscriptionViewController.swift
//  BibleGuardian
//
//  Created by Avazu Holding on 2019/1/16.
//  Copyright © 2019 Avazu Holding. All rights reserved.
//

import UIKit
import SwiftyStoreKit

class SubscriptionViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

		
		NotificationCenter.default.addObserver(self, selector: #selector(subscriptionStateChanged(notify:)), name: NSNotification.Name.init(SubscriptionStateNotifyKey), object: nil)
    }

	@objc private func subscriptionStateChanged(notify: Notification) {
		//接收通知，如果变成vip，代表内购成功，移除当前页
		if InPurchaseManager.manager.isVip {
			self.dismiss(animated: true, completion: nil)
		}
	}
	
	func buy() {
		//通过productId 向appstore 校验，生成product进行购买
		if SwiftyStoreKit.canMakePayments {
			
			//begin loading
			self.view.pleaseWait()
			//purchase
			purchaseProduct(productId: ProductId, applicationUsername: ApplicationUsername)
		}else {
			self.showAlert(self.alertWithTitle("Tips", message: "Please enable app in-purchase function"))
			print("Please enable app in-purchase function")
		}
	}
	//MARK: -- SwiftyStoreKit 使用
	
	//传入productId,直接购买
	private func purchaseProduct(productId: String, applicationUsername: String) {
		
		//atomically理解： apple建议在购买或恢复购买成功时，及时的调用finishTransaction。如果选择了atomically，那么在block回调中会立即调用finishTransaction，如果需要跟服务端交互验证的，应该选择 nonatomically
		SwiftyStoreKit.purchaseProduct(productId, quantity: 1, atomically: true, applicationUsername: applicationUsername, simulatesAskToBuyInSandbox: false) { (result) in
			
			//购买成功
			if case .success(let purchase) = result {
				print("Purchase Success: \(purchase.productId)")
				if purchase.needsFinishTransaction {
					SwiftyStoreKit.finishTransaction(purchase.transaction)
				}
				
				self.verifyReceipt(sharedSecret: AppSecretKey ,productId: productId)
			} else {
				self.view.clearAllNotice()
			}
			
			//错误提示
			if let alert = self.alertForPurchaseResult(result) {
				self.showAlert(alert)
			}
		}
	}
	
	//恢复购买
	private func restorePurchase() {
		self.view.pleaseWait()
		SwiftyStoreKit.restorePurchases { (results) in
			if results.restoreFailedPurchases.count > 0 {
				print("Restore Failed: \(results.restoreFailedPurchases)")
				self.showAlert(self.alertForRestorePurchases(results))
				self.view.clearAllNotice()
			}
			else if results.restoredPurchases.count > 0 {
				print("Restore Success: \(results.restoredPurchases)")
				self.verifyReceipt(sharedSecret: AppSecretKey, productId: ProductId)
			}
			else {
				print("Nothing to Restore")
				self.showAlert(self.alertForRestorePurchases(results))
				self.view.clearAllNotice()
			}
			
		}
	}
	
	//校验收据,确认购买是否有效
	private func verifyReceipt(sharedSecret: String?, productId: String) {
		
		var serViceType: AppleReceiptValidator.VerifyReceiptURLType = .production
		#if DEBUG
		serViceType = .sandbox
		#else
		#endif
		
		let appleValidator = AppleReceiptValidator(service: serViceType, sharedSecret: sharedSecret)
		SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
			switch result {
			case .success(let receipt):
				// Verify the purchase of a Subscription
				let purchaseResult = SwiftyStoreKit.verifySubscription(
					ofType: .autoRenewable, // or .nonRenewing (see below)
					productId: productId,
					inReceipt: receipt)
				//校验结果
				switch purchaseResult {
				case .purchased(let expiryDate, let items):
					
					print("\(productId) is valid until \(expiryDate)\n\(items)\n")
					//校验通过
					UserDefaults.standard.set(true, forKey: UserDefaultStoreVIPKey)
					UserDefaults.standard.set(expiryDate, forKey: UserDefaultExpiredTimeKey)
					self.showAlert(self.alertWithTitle("Product is purchased", message: "Product is valid until \(expiryDate)"))
				case .expired(let expiryDate, let items):
					
					//已过期
					print("\(productId) is expired since \(expiryDate)\n\(items)\n")
					UserDefaults.standard.set(false, forKey: UserDefaultStoreVIPKey)
					self.showAlert(self.alertWithTitle("Product expired", message: "Product is expired since \(expiryDate)"))
				case .notPurchased:
					//未购买
					self.showAlert(self.alertWithTitle("Not purchased", message: "This product has never been purchased"))
				}
				//发送通知刷新状态
				NotificationCenter.default.post(name: NSNotification.Name.init(SubscriptionStateNotifyKey), object: nil)
				
			case .error:
				self.showAlert(self.alertForVerifyReceipt(result))
			}
			self.view.clearAllNotice()
			
		}
	}
	//end
	deinit {
		print("deinit")
	}

}

// MARK: User facing alerts
extension SubscriptionViewController {
	
	func alertWithTitle(_ title: String, message: String) -> UIAlertController {
		
		let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
		return alert
	}
	
	func showAlert(_ alert: UIAlertController) {
		guard self.presentedViewController != nil else {
			self.present(alert, animated: true, completion: nil)
			return
		}
	}
	
	func alertForProductRetrievalInfo(_ result: RetrieveResults) -> UIAlertController {
		
		if let product = result.retrievedProducts.first {
			let priceString = product.localizedPrice!
			return alertWithTitle(product.localizedTitle, message: "\(product.localizedDescription) - \(priceString)")
		} else if let invalidProductId = result.invalidProductIDs.first {
			return alertWithTitle("Could not retrieve product info", message: "Invalid product identifier: \(invalidProductId)")
		} else {
			let errorString = result.error?.localizedDescription ?? "Unknown error. Please contact support"
			return alertWithTitle("Could not retrieve product info", message: errorString)
		}
	}
	
	// swiftlint:disable cyclomatic_complexity
	func alertForPurchaseResult(_ result: PurchaseResult) -> UIAlertController? {
		switch result {
		case .success(let purchase):
			print("Purchase Success: \(purchase.productId)")
			return nil
		case .error(let error):
			print("Purchase Failed: \(error)")
			switch error.code {
			case .unknown: return alertWithTitle("Purchase failed", message: error.localizedDescription)
			case .clientInvalid: // client is not allowed to issue the request, etc.
				return alertWithTitle("Purchase failed", message: "Not allowed to make the payment")
			case .paymentCancelled: // user cancelled the request, etc.
				return nil
			case .paymentInvalid: // purchase identifier was invalid, etc.
				return alertWithTitle("Purchase failed", message: "The purchase identifier was invalid")
			case .paymentNotAllowed: // this device is not allowed to make the payment
				return alertWithTitle("Purchase failed", message: "The device is not allowed to make the payment")
			case .storeProductNotAvailable: // Product is not available in the current storefront
				return alertWithTitle("Purchase failed", message: "The product is not available in the current storefront")
			case .cloudServicePermissionDenied: // user has not allowed access to cloud service information
				return alertWithTitle("Purchase failed", message: "Access to cloud service information is not allowed")
			case .cloudServiceNetworkConnectionFailed: // the device could not connect to the nework
				return alertWithTitle("Purchase failed", message: "Could not connect to the network")
			case .cloudServiceRevoked: // user has revoked permission to use this cloud service
				return alertWithTitle("Purchase failed", message: "Cloud service was revoked")
			default:
				return alertWithTitle("Purchase failed", message: (error as NSError).localizedDescription)
			}
		}
	}
	
	func alertForRestorePurchases(_ results: RestoreResults) -> UIAlertController {
		
		if results.restoreFailedPurchases.count > 0 {
			print("Restore Failed: \(results.restoreFailedPurchases)")
			return alertWithTitle("Restore failed", message: "Unknown error. Please contact support")
		} else if results.restoredPurchases.count > 0 {
			print("Restore Success: \(results.restoredPurchases)")
			return alertWithTitle("Purchases Restored", message: "All purchases have been restored")
		} else {
			print("Nothing to Restore")
			return alertWithTitle("Nothing to restore", message: "No previous purchases were found")
		}
	}
	
	func alertForVerifyReceipt(_ result: VerifyReceiptResult) -> UIAlertController {
		
		switch result {
		case .success(let receipt):
			print("Verify receipt Success: \(receipt)")
			return alertWithTitle("Receipt verified", message: "Receipt verified remotely")
		case .error(let error):
			print("Verify receipt Failed: \(error)")
			switch error {
			case .noReceiptData:
				return alertWithTitle("Receipt verification", message: "No receipt data. Try again.")
			case .networkError(let error):
				return alertWithTitle("Receipt verification", message: "Network error while verifying receipt: \(error)")
			default:
				return alertWithTitle("Receipt verification", message: "Receipt verification failed: \(error)")
			}
		}
	}
	
	func alertForVerifySubscriptions(_ result: VerifySubscriptionResult, productIds: Set<String>) -> UIAlertController {
		
		switch result {
		case .purchased(let expiryDate, let items):
			print("\(productIds) is valid until \(expiryDate)\n\(items)\n")
			return alertWithTitle("Product is purchased", message: "Product is valid until \(expiryDate)")
		case .expired(let expiryDate, let items):
			print("\(productIds) is expired since \(expiryDate)\n\(items)\n")
			return alertWithTitle("Product expired", message: "Product is expired since \(expiryDate)")
		case .notPurchased:
			print("\(productIds) has never been purchased")
			return alertWithTitle("Not purchased", message: "This product has never been purchased")
		}
	}
	
	func alertForVerifyPurchase(_ result: VerifyPurchaseResult, productId: String) -> UIAlertController {
		
		switch result {
		case .purchased:
			print("\(productId) is purchased")
			return alertWithTitle("Product is purchased", message: "Product will not expire")
		case .notPurchased:
			print("\(productId) has never been purchased")
			return alertWithTitle("Not purchased", message: "This product has never been purchased")
		}
	}
}
