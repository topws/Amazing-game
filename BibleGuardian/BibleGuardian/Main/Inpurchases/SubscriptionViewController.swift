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

        purchaseProduct(productId: ProductId, applicationUsername: ApplicationUsername)
    }

	//恢复购买
	private func restorePurchase() {
		SwiftyStoreKit.restorePurchases { (results) in
			if results.restoreFailedPurchases.count > 0 {
				print("Restore Failed: \(results.restoreFailedPurchases)")
			}
			else if results.restoredPurchases.count > 0 {
				print("Restore Success: \(results.restoredPurchases)")
				self.verifyReceipt(sharedSecret: AppSecretKey, productId: ProductId)
			}
			else {
				print("Nothing to Restore")
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
					UserDefaults.standard.set(true, forKey: UserDefaultStoreVIPKey)
				case .expired(let expiryDate, let items):
					print("\(productId) is expired since \(expiryDate)\n\(items)\n")
					UserDefaults.standard.set(false, forKey: UserDefaultStoreVIPKey)
				case .notPurchased:
					print("The user has never purchased \(productId)")
				}
				
			case .error(let error):
				print("Receipt verification failed: \(error)")
			}
		}
	}
	//传入productId,直接购买
	private func purchaseProduct(productId: String, applicationUsername: String) {
		
		//atomically理解： apple建议在购买或恢复购买成功时，及时的调用finishTransaction。如果选择了atomically，那么在block回调中会立即调用finishTransaction，如果需要跟服务端交互验证的，应该选择 nonatomically
		SwiftyStoreKit.purchaseProduct(productId, quantity: 1, atomically: true, applicationUsername: applicationUsername, simulatesAskToBuyInSandbox: false) { (result) in
			
			switch result {
			case .success(let purchase):
				print("Purchase Success: \(purchase.productId)")
				if purchase.needsFinishTransaction {
					SwiftyStoreKit.finishTransaction(purchase.transaction)
				}
				
				self.verifyReceipt(sharedSecret: AppSecretKey ,productId: productId)
				
			case .error(let error):
				switch error.code {
				case .unknown: print("Unknown error. Please contact support")
				case .clientInvalid: print("Not allowed to make the payment")
				case .paymentCancelled: break
				case .paymentInvalid: print("The purchase identifier was invalid")
				case .paymentNotAllowed: print("The device is not allowed to make the payment")
				case .storeProductNotAvailable: print("The product is not available in the current storefront")
				case .cloudServicePermissionDenied: print("Access to cloud service information is not allowed")
				case .cloudServiceNetworkConnectionFailed: print("Could not connect to the network")
				case .cloudServiceRevoked: print("User has revoked permission to use this cloud service")
				default: print((error as NSError).localizedDescription)
				}
			}
		}
	}

}
