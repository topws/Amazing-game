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

class MainViewController: UIViewController {
    
    var scene: GameScene!
    var level: Level!

    override func viewDidLoad() {
        super.viewDidLoad()

		
		setupViews()
    }
	private func setupViews() {
		let words: [String] = ["konw","birds","meant"]//,"caged","are","bright"]
		
		let times = Date()
		let coordinates = getCoordinates(words: words.reversed())
		print(coordinates)
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
        level.convertLetters(coordinates: coordinates)
        level.answerWords = words
        scene.level = level
		
		beginGame()
	}
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        setupViews()
//    }
    
    func beginGame() {
        scene.addSprites(for: level.letters)
    }

	private let maxNum = 8
	private func getCoordinates(words: [String]) -> [WordCoordinateStruct] {
		if words.count < 2 {
			return []
		}
		var contents: [String] = words
		var structs: [WordCoordinateStruct] = []
		var coordinates: [GameCoordinate] = []
		var names: [String] = []
		//计算第一个单词数组的坐标
		let firstWords: [Character] = Array.init(String(contents.first!))
		
		let firstX = (maxNum - firstWords.count) / 2
		for (index,word) in firstWords.enumerated() {
			
			coordinates.append(GameCoordinate(x: (firstX + index), y: 0))
			names.append(String(word))
		}
		//计算余下的单词数组坐标
		contents.removeFirst()
		var portNums = [4,5,6,3,7]
		for word in contents {
			
			let characters = Array.init(word)
			let random = Int.randomIntNumber(lower: 0, upper: 2)
			if random == 0 {//竖向分布
				//判断竖向插入的位置
				//当前算法仅从4，5，6，3，7，五个位置继续竖向插入，依次判断，如果可以插入则插入，如果不可以就往后推，全部不行则改成横向分布
				//竖向的插入规则为从底部向上插入（最下面一排的及其当前位置上面的单词 集体右移，如果当前X轴的位置还有其他的单词则这些单词仅向上平移）
				if portNums.count == 0 {
					let tuple = horizontalInsert(characters: characters, coordinates: coordinates, names: names)
					names = tuple.0
					coordinates = tuple.1
				}else {
					var insertX: Int = 0
					if characters.count < Int(Float(maxNum) * 0.5) {
						//短词拼接在偏的位置
						insertX = portNums.removeLast()
						//
					}else {
						insertX = portNums.removeFirst()
					}
					//校验当前位置上的单词长度加上插入的单词长度是否超过了界限
					var insertCount: Int = 0
					for coordinate in coordinates {
						if coordinate.x == insertX {
							insertCount += 1
						}
					}
					if (insertCount + characters.count) > maxNum {
						let tuple = horizontalInsert(characters: characters, coordinates: coordinates, names: names)
						names = tuple.0
						coordinates = tuple.1
					}else {
						//开始插入
						var bottomCount = 0
						for coordinate in coordinates {
							if coordinate.y == 0 {
								bottomCount += 1
							}
						}
						if bottomCount < maxNum - 1 {//可以从底部插入
							//先变动已有的坐标
							if insertCount == 1 {
								//直接右移
								for (index,coordinate) in coordinates.enumerated() {
									if coordinate.x >= insertX - 1  {
										let newPoint = GameCoordinate(x: coordinate.x + 1, y: coordinate.y)
										coordinates[index] = newPoint
									}
								}
								//再新增插入的坐标
								for (index,word) in characters.enumerated() {
									names.append(String(word))
									coordinates.append(GameCoordinate(x: insertX - 1, y: characters.count - 1 - index))
								}
							}else {
								//在当前轴上插入
								for (index,coordinate) in coordinates.enumerated() {
									if coordinate.x == insertX - 1 && coordinate.y > 0 {
										let newPoint = GameCoordinate(x: coordinate.x, y: coordinate.y + characters.count)
										coordinates[index] = newPoint
									}
								}
								for (index,word) in characters.enumerated() {
									names.append(String(word))
									coordinates.append(GameCoordinate(x: insertX - 1, y: characters.count - index))
								}
							}
							
						}else {
							print("warning ---------当前竖向插入后X轴超长，导致只能插入在X轴所有单词之上---------warning")
							
							for (index,word) in characters.enumerated() {
								names.append(String(word))
								coordinates.append(GameCoordinate(x: insertX - 1, y: characters.count - 1 - index + insertCount))
							}
						}
					}
				}
				
			}else {
				
				let tuple = horizontalInsert(characters: characters, coordinates: coordinates, names: names)
				names = tuple.0
				coordinates = tuple.1
			}
		}
		//合并
		for (index,coordinate) in coordinates.enumerated() {
			structs.append(WordCoordinateStruct.init(name: names[index], point: coordinate))
		}
		return structs
	}
	private func horizontalInsert(characters: [Character],coordinates: [GameCoordinate],names: [String]) -> ([String],[GameCoordinate]) {
		
		var newNames = names
		var newCoordinates = coordinates
		//横向分布
		let contentX = (maxNum - characters.count) / 2
		//计算最新的单词坐标前，先把数组中以后的单词坐标往上平移一个位置
		let needRefreshX: Range = contentX..<characters.count
		for (index,point) in coordinates.enumerated() {
			//如果包含在刷新区间内，Y轴平移
			if needRefreshX.contains(point.x) {
				let newPoint = GameCoordinate(x: point.x, y: point.y + 1)
				newCoordinates[index] = newPoint
			}
		}
		//添加最新单词的坐标
		for (index,word) in characters.enumerated() {
			newNames.append(String(word))
			newCoordinates.append(GameCoordinate(x: contentX + index, y: 0))
		}
		return (newNames,newCoordinates)
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

