//
//  CustomNavViewController.swift
//  SwiftFlashKeyboard
//
//  Created by Avazu Holding on 2018/11/7.
//  Copyright © 2018 Avazu Holding. All rights reserved.
//

import UIKit
import SnapKit
class CustomNavViewController: UIViewController {
	
	let navView:UIView = UIView()
	let navContent:UIView = UIView()
	let backBtn:UIButton = UIButton()
	let navTitle:UILabel = UILabel()
	let contentView:UIView = UIView()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.backgroundColor = UIColor.white
		contentView.backgroundColor = UIColor.white
		
		setUpView()
		
	}
	private func setUpView(){
		
		view.addSubview(navView)
		view.addSubview(contentView)
		let backImageV = UIImageView(image: UIImage(named: "navigationBarBG"))
		backImageV.contentMode = .scaleToFill
		backImageV.isUserInteractionEnabled = true
		navView.addSubview(backImageV)
		backImageV.snp.makeConstraints { (make) in
			make.edges.equalTo(navView)
		}
		navView.addSubview(navContent)
		
		let navHeight: CGFloat = 44
		navContent.snp.makeConstraints { (make) in
			make.bottom.left.right.equalTo(navView)
			make.height.equalTo(navHeight)
		}
		navView.snp.makeConstraints { (make) in
			make.left.equalTo(view)
			make.right.equalTo(view)
			make.height.equalTo(navHeight + SWStatusBarH)
			make.top.equalTo(view).offset(0)
		}
		contentView.snp.makeConstraints { (make) in
			make.top.equalTo(navView.snp.bottom)
			make.left.equalTo(view)
			make.right.equalTo(view)
			make.bottom.equalTo(view)
		}
		
		
		
		backBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 20)
		backBtn.addTarget(self, action: #selector(back), for: .touchUpInside)
		backBtn.setImage(UIImage(named: "icon_leftArrow"), for: .normal)
		
		navTitle.font = UIFont.boldSystemFont(ofSize: 17)
		navTitle.textColor = UIColor.white//UIColor.init(hexColor: "333333")

		navContent.addSubview(backBtn)
		navContent.addSubview(navTitle)
		
		backBtn.snp.makeConstraints { (make) in
			make.centerY.equalTo(navContent)
			make.left.equalTo(navContent).offset(15)
			make.height.width.equalTo(40)
		}
		navTitle.snp.makeConstraints { (make) in
			make.centerY.equalTo(navContent)
			make.centerX.equalTo(navContent)
		}
	}
	
	@objc func back() {
		self.navigationController?.popViewController(animated: true)
	}
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	
}
