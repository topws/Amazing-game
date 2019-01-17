//
//  AppDelegate.swift
//  BibleGuardian
//
//  Created by Avazu Holding on 2019/1/2.
//  Copyright © 2019 Avazu Holding. All rights reserved.
//

import UIKit
import SwiftyStoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
	
	var window: UIWindow?
	
	
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		
		setupWindow()
		
		return true
	}
	
	private func setupWindow() {
		window = UIWindow.init(frame: UIScreen.main.bounds)
		
		let mainVc = MainViewController()
		let vc = FKNavViewController.init(rootViewController: mainVc)
		mainVc.view.backgroundColor = UIColor.white
		vc.navigationBar.isHidden = true
		self.window?.rootViewController = vc
		self.window?.makeKeyAndVisible()
		
	}
	
	//MARK: -- apple recommands to register a transaction observer as soon as the app starts:
	//register a transaction observer as soon as the app starts:
	private func completeTransactions() {
		//completeTransactions
		SwiftyStoreKit.completeTransactions(atomically: true) { (purchases) in
			for purchase in purchases {
				switch purchase.transaction.transactionState {
				case .purchased, .restored:
					if purchase.needsFinishTransaction {
						// Deliver content from server, then:
						SwiftyStoreKit.finishTransaction(purchase.transaction)
					}
				case .failed, .purchasing, .deferred:
					break //do nothing
					
				}
			}
		}
		
		if let expiredTime: Date = UserDefaults.standard.object(forKey: UserDefaultExpiredTimeKey) as? Date {
			//存储的过期时间已经到期
			if expiredTime < Date() {
				verifyReceipt()
			}
		}
		
		
	}
	
	private func verifyReceipt() {
		//校验是否过期,程序启动后如账号未登陆，会请求用户登录APPID
		var serViceType: AppleReceiptValidator.VerifyReceiptURLType = .production
		#if DEBUG
		serViceType = .sandbox
		#else
		#endif
		let appleValidator = AppleReceiptValidator(service: serViceType, sharedSecret: AppSecretKey)
		SwiftyStoreKit.verifyReceipt(using: appleValidator) { (result) in
			switch result {
			case .success(receipt: let receipt):
				let purchaseResult = SwiftyStoreKit.verifySubscription(ofType: .autoRenewable, productId: ProductId, inReceipt: receipt)
				switch purchaseResult{
				case .purchased(let expiryDate, let items):
					print("\(ProductId) is valid until \(expiryDate)\n\(items)\n")
					UserDefaults.standard.set(true, forKey: UserDefaultStoreVIPKey)
					UserDefaults.standard.set(expiryDate, forKey: UserDefaultExpiredTimeKey)
				case .expired(let expiryDate, let items):
					print("\(ProductId) is expired since \(expiryDate)\n\(items)\n")
					UserDefaults.standard.set(false, forKey: UserDefaultStoreVIPKey)
				case .notPurchased:
					print("The user has never purchased \(ProductId)")
				}
				
			case .error(let error):
				print("Receipt verification failed: \(error)")
			}
		}
	}
	func applicationWillResignActive(_ application: UIApplication) {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
	}
	
	func applicationDidEnterBackground(_ application: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	}
	
	func applicationWillEnterForeground(_ application: UIApplication) {
		// Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
	}
	
	func applicationDidBecomeActive(_ application: UIApplication) {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	}
	
	func applicationWillTerminate(_ application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	}
	
	
}

