//
//  AppDelegate.swift
//  BibleGuardian
//
//  Created by Avazu Holding on 2019/1/2.
//  Copyright © 2019 Avazu Holding. All rights reserved.
//

import UIKit
import SocketIO
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?

	var chatSocket: SocketIOClient?
	var socketManager: SocketManager?
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
		
		let dic = ["username" : "手机用户3333",
				   "roomnum":"13089",
				   "stream":"13089_1543458639",
				   "token":"ccc685864e2bda6bf8751a299b2e55d5",
				   "uid":"13110"]
		
		socketManager = SocketManager.init(socketURL: URL(string: "http://172.31.0.124:19967")!, config: [.log(true),.compress])
		chatSocket = socketManager!.defaultSocket
		chatSocket?.on("connect", callback: { (data, ack) in
			print(data)
			self.chatSocket?.emit("conn", with: [dic])
	
			
			
		})
		chatSocket?.on("disconnect", callback: { (data, ack) in
			print("data = \(data)")
		})
		chatSocket?.on("error", callback: { (data, ack) in
			print("data = \(data)")
		})
		chatSocket?.on("conn", callback: { (data, ack) in
			print("data = \(data)")
		})
		chatSocket?.on("broadcastingListen", callback: { (data, ack) in
			print(data)
		})
		
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

