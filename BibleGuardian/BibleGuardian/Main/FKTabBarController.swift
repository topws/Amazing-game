//
//  FlashKeyboardTabBarController.swift
//  SwiftFlashKeyboard
//
//  Created by Avazu Holding on 2018/11/7.
//  Copyright © 2018 Avazu Holding. All rights reserved.
//

import UIKit

class FKTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let color = UIColor.init(hexColor: "E8ECF0")
        self.tabBar.isTranslucent = false
        self.tabBar.barTintColor = color

        self.tabBar.backgroundImage = UIImage.init()
        self.tabBar.shadowImage = UIImage.init()
        
        addChildVcs()
		
    }
    
   
	private func addChildVcs() {
		
		let mainPageNav = FKNavViewController.init(rootViewController: MainViewController())
		setupChildVc(vc: mainPageNav, title: "CollectionGif", image: "emoji", selectedImage: "emoji_selected")
	
		self.addChild(mainPageNav)
		
	}
	
	private func setupChildVc(vc: UINavigationController,title: String,image: String,selectedImage: String) {
//		vc.title = title
		vc.tabBarItem.image = UIImage(named: image)
		vc.tabBarItem.selectedImage = UIImage(named: selectedImage)
//		vc.tabBarItem.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.gray], for: .selected)
	
		vc.tabBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
		vc.navigationBar.isHidden = true
		
	}
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        
        switch item.tag {
        case 0:
			

            break
        case 1:
			

            break
        case 2:
			

            break
        default:
            break
        }
    }
}
