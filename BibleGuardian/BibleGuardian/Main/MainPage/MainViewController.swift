//
//  MainViewController.swift
//  BibleGuardian
//
//  Created by Avazu Holding on 2019/1/2.
//  Copyright © 2019 Avazu Holding. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class MainViewController: UIViewController, GameSceneDelegate {
    
    var scene: GameScene!
    var level: Level!
    private var textLbl: UILabel!
    private var reloadBtn: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

		
		setupViews()
    }
	private func setupViews() {
		let words: [String] = ["konw","birds","meant"]//,"caged","are","bright"
		
		let times = Date()
//        let coordinates = getCoordinates(words: words.reversed())
//        print(coordinates)
		print("randomTime = \(Date().timeIntervalSince(times))")
		
		if let view = self.view as! SKView? {
			// Load the SKScene from 'GameScene.sks'
			scene = GameScene(size: CGSize(width: 300, height: 600))
			// Set the scale mode to scale to fit the window
			scene.scaleMode = .aspectFill
			
			// Present the scene
			view.presentScene(scene)
			
			
			view.ignoresSiblingOrder = true
			
			view.showsFPS = true
			view.showsNodeCount = true
		}
		
		level = Level()
        level.answerWords = words
        level.buildLetters()
        scene.level = level
        scene.sceneDelegate = self
        
        textLbl = UILabel()
        textLbl.backgroundColor = UIColor.blue
        view.addSubview(textLbl)
        
        reloadBtn = UIButton()
        reloadBtn.backgroundColor = UIColor.yellow
        reloadBtn.addTarget(self, action: #selector(reload), for: .touchUpInside)
        view.addSubview(reloadBtn)
		
		beginGame()
	}
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let lblStartPoint = CGPoint(x: scene.labelFrame.origin.x, y: scene.labelFrame.maxY)
        let lblEndPoint = CGPoint(x: scene.labelFrame.maxX, y: scene.labelFrame.minY)
        let startPoint = scene.convertPoint(toView: lblStartPoint)
        let endPoint = scene.convertPoint(toView: lblEndPoint)
        let frame = CGRect(origin: startPoint, size: CGSize(width: endPoint.x - startPoint.x, height: endPoint.y - startPoint.y))
        textLbl.frame = frame
        
        let reloadStartPoint = CGPoint(x: scene.reloadFrame.origin.x, y: scene.reloadFrame.maxY)
        let reloadEndPoint = CGPoint(x: scene.reloadFrame.maxX, y: scene.reloadFrame.minY)
        let btnStartPoint = scene.convertPoint(toView: reloadStartPoint)
        let btnEndPoint = scene.convertPoint(toView: reloadEndPoint)
        let reloadFrame = CGRect(origin: btnStartPoint, size: CGSize(width: btnEndPoint.x - btnStartPoint.x, height: btnEndPoint.y - btnStartPoint.y))
        reloadBtn.frame = reloadFrame
    }

//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        setupViews()
//    }
    
    func beginGame() {
        scene.addSprites(for: level.letters)
    }
    
    func gameSceneDidTappedNext(scene: GameScene) {
        setupViews()
    }
    
    @objc func reload() {
        setupViews()
    }
	
}
struct WordCoordinateStruct {
	let name: String
	let point: GameCoordinate
}
struct GameCoordinate {
	let x: Int
	let y: Int
}
public extension Int {
	/*这是一个内置函数
	lower : 内置为 0，可根据自己要获取的随机数进行修改。
	upper : 内置为 UInt32.max 的最大值，这里防止转化越界，造成的崩溃。
	返回的结果： [lower,upper) 之间的半开半闭区间的数。
	*/
	public static func randomIntNumber(lower: Int = 0,upper: Int = Int(UInt32.max)) -> Int {
		return lower + Int(arc4random_uniform(UInt32(upper - lower)))
	}
	/**
	生成某个区间的随机数
	*/
	public static func randomIntNumber(range: Range<Int>) -> Int {
		return randomIntNumber(lower: range.lowerBound, upper: range.upperBound)
	}
}

