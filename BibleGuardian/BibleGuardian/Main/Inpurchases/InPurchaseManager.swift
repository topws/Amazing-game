//
//  InPurchaseManager.swift
//  LivePaper
//
//  Created by Avazu Holding on 2019/1/16.
//  Copyright © 2019 Avazu. All rights reserved.
//

import Foundation

class InPurchaseManager {
	
	static let manager = InPurchaseManager()
	private init() {}
	
	var isVip: Bool {
		return UserDefaults.standard.bool(forKey: UserDefaultStoreVIPKey)
	}
}
