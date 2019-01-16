//
//  ConstantManager.swift
//  SwiftWallet
//
//  Created by Avazu Holding on 2018/3/21.
//  Copyright © 2018年 DotC United Group. All rights reserved.
//

import Foundation
import UIKit


//屏幕宏
let SWScreen_bounds:CGRect = UIScreen.main.bounds
let SWScreen_width:CGFloat = UIScreen.main.bounds.width
let SWScreen_height:CGFloat = UIScreen.main.bounds.height
let SWStatusBarH:CGFloat = UIApplication.shared.statusBarFrame.size.height
let SWNavBarHeight:CGFloat = 44


//iPhone X
let SafeAreaTopHeight:CGFloat = SWStatusBarH + SWNavBarHeight
let iPhoneXBottomHeight:CGFloat = 34
let iPhoneXScreenHeight:CGFloat = 812.0

//APP info
struct AppInfo {
    let infoDictionary = Bundle.main.infoDictionary
    let appDisplayName: String = Bundle.main.infoDictionary!["CFBundleDisplayName"] as! String
    let bundleID: String = Bundle.main.bundleIdentifier!
    let appVersion: String = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
    let buildVersion: String = Bundle.main.infoDictionary!["CFBundleVersion"] as! String
    let uuid = UIDevice.current.identifierForVendor?.uuidString
    let systemName = UIDevice.current.systemName
}

//Inpurchase
let AppSecretKey = "ad9d5c664ebd44119bcd17ae2b630530"
let ProductId = "1009"
let ApplicationUsername = "BibleGuardian"//如果有账号系统，应该是UserName去标识
let UserDefaultStoreVIPKey = "UserDefaultStoreVIPKey"

