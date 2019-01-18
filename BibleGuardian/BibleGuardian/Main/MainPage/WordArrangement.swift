//
//  WordArrangement.swift
//  BibleGuardian
//
//  Created by Avazu Holding on 2019/1/17.
//  Copyright © 2019 Avazu Holding. All rights reserved.
//

import Foundation
import UIKit

class WordArrangement {
	static let manager = WordArrangement()
	private init() {}
	
	private let defaultMaxX = 8
	private let defaultMaxY = 8
	//生成二维数组坐标，核心要求满足正态分布图的趋势
	func getCoordinates(words: [String]) -> [WordCoordinateStruct] {
		if words.count == 0 {
			return []
		}
		//需要排列的单词
		var contents: [String] = words
		
		//首先横向 布局第一个单词
		var structs: [WordCoordinateStruct] = arrangeFirstWord(word: words.first!, isHorizontal: true)
		contents.removeFirst()
		
		//依次布局其他的单词
		for word in contents {
			
			let characters = Array.init(word)
			let random = Int.randomIntNumber(lower: 0, upper: 2)
			
			if random == 0 {
				//竖向插入
				structs = verticalInsert(characters: characters, structs: structs)
			} else {
				//横向插入
				structs = horizontalInsert(characters: characters, structs: structs)
			}
			
		}
		//计算当前的坐标数组中的 X轴和Y轴最大值
		var maxX: Int = 0
		var maxY: Int = 0
		for model in structs {
			maxX = (model.point.x > maxX) ? model.point.x : maxX
			maxY = (model.point.y > maxY) ? model.point.y : maxY
		}
		if maxY >= defaultMaxY || maxX >= defaultMaxX {
			print("warnning max 超出")
		}
		return structs
	}
	
	//MARK: -- 竖向插入，寻求合适的输入点进行竖向插入，需要验证插入的高度
	private func verticalInsert(characters: [Character], structs: [WordCoordinateStruct]) -> [WordCoordinateStruct] {
		
		var structs = structs

		//再取随机数，竖向 向下插入和 竖向向上插入
		if characters.count > defaultMaxX / 2 {
			
			//竖向 向下插入，所以大于X轴的 数据右移
			//先判断横向X轴 是否足够
			let tuple = getMaxCoordinateX(structs: structs)
			let count = tuple.0
			let insertRange = tuple.1
			if count + 1 > defaultMaxX {
				//超过限制，无法右移插入，变更为竖向 向上插入
				print("warning---超过限制，无法右移插入，变更为竖向 向上插入")
				structs = verticalInsertSomePoint(characters: characters, structs: structs)
			} else {
				
				let insertCol = Int.randomIntNumber(range: insertRange)
				//TODO: ---后续可以继续加逻辑，判断如果随机的 插入列为边界的话，可以再加上 优先两侧移动，增加难度（减少完整的单词出现）
				//判断左移还是右移(判断单词两侧的间距)
				if (defaultMaxX - insertRange.upperBound) > insertRange.lowerBound {
					//右移
					for (index, word) in structs.enumerated() {
						//刷新需要移动的字母
						if word.point.x >= insertCol {
							let newPoint = GameCoordinate(x: word.point.x + 1, y: word.point.y)
							structs[index] = WordCoordinateStruct(name: word.name, point: newPoint)
						}
					}
				}else {
					//左移
					for (index, word) in structs.enumerated() {
						//刷新需要移动的字母
						if word.point.x <= insertCol {
							let newPoint = GameCoordinate(x: word.point.x - 1, y: word.point.y)
							structs[index] = WordCoordinateStruct(name: word.name, point: newPoint)
						}
					}
					
				}

				//新增此列单词
				for (index, word) in characters.enumerated() {
					structs.append(WordCoordinateStruct(name: String(word), point: GameCoordinate(x: insertCol, y: characters.count - index - 1)))
				}
			}
			
		} else {
			//竖向 向上插入,顶起原有 X轴的 数据
			structs = verticalInsertSomePoint(characters: characters, structs: structs)
		}
		
		return structs
	}
	//MARK: -- 竖向 向上插入,顶起原有 X轴的 数据
	private func verticalInsertSomePoint(characters: [Character], structs: [WordCoordinateStruct]) -> [WordCoordinateStruct] {
		var structs = structs
		let insertCount = characters.count
		//根据要插入的单词长度，来找合适的插入列
		
		//计算各列的原有高度
		let tuple = getMaxCoordinateX(structs: structs)
		var coordinateMaxYs: [GameCoordinate] = []//GameCoordinate这里X代表X轴，Y代表X轴上的最大值
		for x in tuple.1 {
			coordinateMaxYs.append(GameCoordinate(x: x, y: 0))
		}
		//z坐标上，X轴对应的Y轴最大值
		for model in structs {
			
			if model.point.x >= tuple.1.lowerBound && model.point.x < tuple.1.upperBound {
				
				
				for (index, coordinatemaxY) in coordinateMaxYs.enumerated() {
					if coordinatemaxY.x == model.point.x {
						let maxY = (coordinatemaxY.y > model.point.y) ? coordinatemaxY.y : model.point.y
						coordinateMaxYs[index] = GameCoordinate(x: coordinatemaxY.x, y: maxY)
					}
				}
				
			}
		}
		//校验那些列可以插入
		var canInsertX: [Int] = []
		for coordinate in coordinateMaxYs {
			if coordinate.y + insertCount < defaultMaxY {
				canInsertX.append(coordinate.x)
			}
		}
		
		if canInsertX.count == 0 {
			//没有可以插入的值
			print("warning---超过限制，无法竖向 向上插入，变更为横向插入")
			structs = horizontalInsert(characters: characters, structs: structs)
		}
		//取出能插入的X轴上的所有元素，随机一个点进行插入
		var canInsertCoordinates: [GameCoordinate] = []
		for model in structs {
			if canInsertX.contains(model.point.x) {
				canInsertCoordinates.append(model.point)
			}
		}
		let insertCoordinateIndex = Int.randomIntNumber(lower: 0, upper: canInsertCoordinates.count)
		let insertCoordinate = canInsertCoordinates[insertCoordinateIndex]
		//已找到点 开始插入
		//刷新需要变更的点
		for (index, model) in structs.enumerated() {
			if model.point.x == insertCoordinate.x && model.point.y >= insertCoordinate.y {
				structs[index] = WordCoordinateStruct(name: model.name, point: GameCoordinate(x: model.point.x, y: model.point.y + characters.count))
			}
		}
		//新增单词的坐标
		for (index, word) in characters.enumerated() {
			structs.append(WordCoordinateStruct(name: String(word), point: GameCoordinate(x: insertCoordinate.x, y: insertCoordinate.y + (insertCount - index - 1))))
		}
		return structs
	}
	
	//MARK: -- 横向插入，暂定为全部从底部往上插入（后续变更为，寻找合适的插入点进行横向插入）
	private func horizontalInsert(characters: [Character], structs: [WordCoordinateStruct]) -> [WordCoordinateStruct] {
		
		var structs = structs
		//寻找底部插入的合适初始位置
		let contentX = (defaultMaxX - characters.count) / 2
		//计算最新的单词坐标前x，先把数组中以后的单词坐标往上平移一个位置
		let needRefreshX: Range = contentX ..< (characters.count + contentX)
		for (index, model) in structs.enumerated() {
			
			if needRefreshX.contains(model.point.x) {
				let newPoint = GameCoordinate.init(x: model.point.x, y: model.point.y  + 1)
				structs[index] = WordCoordinateStruct(name: model.name, point: newPoint)
			}
		}
		//添加最新单词的坐标
		for (index, word) in characters.enumerated() {
			structs.append(WordCoordinateStruct(name: String(word), point: GameCoordinate(x: contentX + index, y: 0)))
		}
		return structs
	}
	
	//MARK: -- 生成第一个单词的排列(暂定全为 横向排布)
	private func arrangeFirstWord(word: String, isHorizontal: Bool) -> [WordCoordinateStruct] {
		let firstWords: [Character] = Array.init(word)
		
		var structs: [WordCoordinateStruct] = []
		//计算出初始位置
		let firstX = (defaultMaxX - firstWords.count) / 2
		for (index, word) in firstWords.enumerated() {
			
			let name = String(word)
			let coordinate = GameCoordinate(x: (firstX + index), y: 0)
			
			structs.append(WordCoordinateStruct(name: name, point: coordinate))
		}
		
		return structs
	}
	
	//MARK: -- 获取坐标系中 Y轴为0 的个数和 X轴有值的Range，用于校验能否 元素右移
	private func getMaxCoordinateX(structs: [WordCoordinateStruct]) -> (Int, Range<Int>) {
		
		//Y轴为0时，X轴的总数，以及X轴的有值的范围
		var count: Int = 0
		var minX: Int = 1000
		
		for model in structs {
			
			if model.point.y == 0 {
				count += 1
				minX = (minX < model.point.x) ? minX : model.point.x
			}
		}
		
		return (count, (minX..<(minX + count)))
	}
	
}
