//
//  GameScene.swift
//  GameTest
//
//  Created by Avazu on 2018/12/24.
//  Copyright © 2018年 Ken. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    private var progressBar: SKSpriteNode?
    private var heart: SKSpriteNode?
    
    var level: Level!
    
    let tileWidth: CGFloat = 32.0
    let tileHeight: CGFloat = 36.0
    
    let gameLayer = SKNode()
    let cookiesLayer = SKNode()
    
    var startPoint: (Int, Int)?
    var currentPoint: (Int, Int)?
    var swipeVerticle: Bool?
    
    override init(size: CGSize) {
        super.init(size: size)
        
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        addChild(gameLayer)
        
        let layerPosition = CGPoint(
            x: -tileWidth * CGFloat(numColumns) / 2,
            y: -tileHeight * CGFloat(numRows) / 2)
        
        cookiesLayer.position = layerPosition
        gameLayer.addChild(cookiesLayer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addSprites(for allLetters: [[Letter?]]) {
        for letters in allLetters {
            for letter in letters {
                guard let letter = letter else { continue }
                let sprite = SKSpriteNode()
                sprite.anchorPoint = CGPoint(x: 0.5, y: 0.5)
                let lbl = SKLabelNode(text: letter.type.rawValue)
                lbl.position = CGPoint(x: 0, y: -tileHeight / 2)
                sprite.addChild(lbl)
                sprite.size = CGSize(width: tileWidth, height: tileHeight)
                sprite.position = pointFor(column: letter.column, row: letter.row)
                cookiesLayer.addChild(sprite)
                letter.sprite = sprite
            }
        }
    }
    
    private func pointFor(column: Int, row: Int) -> CGPoint {
        return CGPoint(
            x: CGFloat(column) * tileWidth + tileWidth / 2,
            y: CGFloat(row) * tileHeight + tileHeight / 2)
    }
    
    private func convertPoint(_ point: CGPoint) -> (success: Bool, column: Int, row: Int) {
        if point.x >= 0 && point.x < CGFloat(numColumns) * tileWidth &&
            point.y >= 0 && point.y < CGFloat(numRows) * tileHeight {
            return (true, Int(point.x / tileWidth), Int(point.y / tileHeight))
        } else {
            return (false, 0, 0)  // invalid location
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 1
        guard let touch = touches.first else { return }
        let location = touch.location(in: cookiesLayer)
        // 2
        let (success, column, row) = convertPoint(location)
        if success {
            // 3
            if let letter = level.letter(atColumn: column, row: row) {
                // 4
                startPoint = (column, row)
                currentPoint = (column, row)
                letter.isSelected = true
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 1
        guard let startPoint = startPoint, let currentPoint = currentPoint else { return }
        // 2
        guard let touch = touches.first else { return }
        let location = touch.location(in: cookiesLayer)
        
        let (success, column, row) = convertPoint(location)
        
        if currentPoint == (column, row) { return } else {
            self.currentPoint = (column, row)
        }
        
        if success {
            let (startColumn, startRow) = startPoint
            if swipeVerticle == nil {
                // 第二格确定方向
                if let letter = level.letter(atColumn: column, row: row) {
                    if column != startColumn {          // swipe horizontal
                        swipeVerticle = false
                    } else if row != startRow {         // swipe verticle
                        swipeVerticle = true
                    }
                    letter.isSelected = true
                }
            } else {
                var selectedArray: [Letter] = []
                if swipeVerticle == true {
                    // 垂直
                    for letters in level.letters {
                        for letter in letters {
                            guard let letter = letter else { continue }
                            let minRow = row < startRow ? row : startRow
                            let maxRow = row > startRow ? row : startRow
                            if letter.column == startColumn {
                                if letter.row <= maxRow && letter.row >= minRow {
//                                    letter.isSelected = true
                                    selectedArray.append(letter)
                                    continue
                                }
                            }
                            letter.isSelected = false
                        }
                    }
                    // 检测断开
                    for letter in selectedArray {
                        let start = letter.row < startRow ? letter.row : startRow
                        let end = letter.row > startRow ? letter.row : startRow
                        var isLink = false
                        for i in start ... end {
                            isLink = false
                            for otherLetter in selectedArray {
                                if otherLetter.row == i {
                                    isLink = true
                                    break
                                }
                            }
                            if !isLink { break }
                        }
                        if isLink {
                            letter.isSelected = true
                        }
                    }
                } else if swipeVerticle == false {
//                    for letters in level.letters {
//                        for letter in letters {
//                            guard let letter = letter else { continue }
//                            let minColumn = column < startColumn ? column : startColumn
//                            let maxColumn = column > startColumn ? column : startColumn
//                            if letter.row == startRow {
//                                if letter.column <= maxColumn && letter.column >= minColumn {
////                                    letter.isSelected = true
//                                    selectedArray.append(letter)
//                                    break
//                                }
//                            }
//                            letter.isSelected = false
//                        }
//                    }
                    // 水平
                    for letters in level.letters {
                        for letter in letters {
                            guard let letter = letter else { continue }
                            let minColumn = column < startColumn ? column : startColumn
                            let maxColumn = column > startColumn ? column : startColumn
                            if letter.row == startRow {
                                if letter.column <= maxColumn && letter.column >= minColumn {
                                    selectedArray.append(letter)
                                    continue
                                }
                            }
                            letter.isSelected = false
                        }
                    }
                    // 检测断开
                    for letter in selectedArray {
                        let start = letter.column < startColumn ? letter.column : startColumn
                        let end = letter.column > startColumn ? letter.column : startColumn
                        var isLink = false
                        for i in start ... end {
                            isLink = false
                            for otherLetter in selectedArray {
                                if otherLetter.column == i {
                                    isLink = true
                                    break
                                }
                            }
                            if !isLink { break }
                        }
                        if isLink {
                            letter.isSelected = true
                        }
                    }
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        var selectedLetters: [Letter] = []
        for letters in level.letters {
            for letter in letters {
                guard let letter = letter else { continue }
                if letter.isSelected {
                    selectedLetters.append(letter)
                }
            }
        }
        
        var word = ""
        if swipeVerticle == true {
            selectedLetters = selectedLetters.reversed()
        }
        for letter in selectedLetters {
            word += letter.type.rawValue
            letter.isSelected = false
        }
        if level.isWordBingo(word: word) {
            removeWord(selectedLetters: selectedLetters)
            rearrangeMap(selectedLetters: selectedLetters)
        }
        startPoint = nil
        currentPoint = nil
        swipeVerticle = nil
    }
    
    func removeWord(selectedLetters: [Letter]) {
        for letter in selectedLetters {
            if let sprite = letter.sprite {
                if sprite.action(forKey: "removing") == nil {
                    let scaleAction = SKAction.scale(to: 0.1, duration: 0.3)
                    scaleAction.timingMode = .easeOut
                    sprite.run(SKAction.sequence([scaleAction, SKAction.removeFromParent()]),
                               withKey: "removing")
                }
            }
            level.letters[letter.column][letter.row] = nil
        }
    }
    
    func rearrangeMap(selectedLetters: [Letter]) {
        // 优先下落
        var isDrop = false
        var columns: [Int] = []
        var rows: [Int] = []
        if swipeVerticle == true {
            columns = [selectedLetters[0].column]
        } else {
            rows = [selectedLetters[0].row]
        }
        let topRow = selectedLetters.last!.row
        for letter in selectedLetters {
            if swipeVerticle == true {
                rows.append(letter.row)
            } else {
                columns.append(letter.column)
            }
            if letter.row == topRow {
                if let _ = level.letter(atColumn: letter.column, row: topRow + 1) {
                    isDrop = true
                    break
                }
            }
        }
        
        if isDrop {
            var animateLetters: [Letter] = []
            for col in columns {
                for letter in (level.letters[col]) {
                    guard let letter = letter else { continue }
                    if letter.row > rows[0]
                        && level.letters[col][letter.row - 1] == nil
                    {
                        level.letters[col][letter.row - 1] = letter
                        animateLetters.append(letter)
                    }
                }
            }
            animateFallingLetters(in: animateLetters) {
                
            }
        }
    }
    
    func animateFallingLetters(in columns: [Letter], completion: @escaping () -> Void) {
        // 1
        var longestDuration: TimeInterval = 0
//        for array in columns {
            for (index, letter) in columns.enumerated() {
                let newPosition = pointFor(column: letter.column, row: letter.row)
                // 2
                let delay = 0.05 + 0.15 * TimeInterval(index)
                // 3
                let sprite = letter.sprite!   // sprite always exists at this point
                let duration = TimeInterval(((sprite.position.y - newPosition.y) / tileHeight) * 0.1)
                // 4
                longestDuration = max(longestDuration, duration + delay)
                // 5
                let moveAction = SKAction.move(to: newPosition, duration: duration)
                moveAction.timingMode = .easeOut
                sprite.run(
                    SKAction.sequence([
                        SKAction.wait(forDuration: delay),
                        SKAction.group([moveAction])//, fallingCookieSound])]))
                    ])
                )
            }
//        }
        
        // 6
        run(SKAction.wait(forDuration: longestDuration), completion: completion)
    }
    
    override func didMove(to view: SKView) {
        
        // Get label node from scene and store it for use later
        self.label = self.childNode(withName: "//helloLabel") as? SKLabelNode
        if let label = self.label {
            label.alpha = 0.0
            label.run(SKAction.fadeIn(withDuration: 2.0))
        }
        
        // Create shape node to use during mouse interaction
        let w = (self.size.width + self.size.height) * 0.05
        self.spinnyNode = SKShapeNode.init(rectOf: CGSize.init(width: w, height: w), cornerRadius: w * 0.3)
        
        if let spinnyNode = self.spinnyNode {
            spinnyNode.lineWidth = 2.5
            
            spinnyNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 1)))
            spinnyNode.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
                                              SKAction.fadeOut(withDuration: 0.5),
                                              SKAction.removeFromParent()]))
        }
        
        self.progressBar = self.childNode(withName: "//timeBar") as? SKSpriteNode
        if let bar = self.progressBar {
            let timer = Timer(timeInterval: 0.1, target: self, selector: #selector(reduceTime), userInfo: nil, repeats: true)
            RunLoop.current.add(timer, forMode: .default)
        }
        self.heart = self.childNode(withName: "//heart") as? SKSpriteNode
        if let heart = self.heart {
            let flipSequence = SKAction.sequence([SKAction.scaleX(to: 0.1, duration: 1), SKAction.scaleX(to: 100, duration: 1), SKAction.scaleX(to: 0.1, duration: 1), SKAction.scaleX(to: 286, duration: 1)])
            let changeContentSequence = SKAction.sequence([SKAction.wait(forDuration: 1), SKAction.setTexture(SKTexture(imageNamed: "heart")), SKAction.wait(forDuration: 2), SKAction.setTexture(SKTexture(imageNamed: "unheart")), SKAction.wait(forDuration: 1)])
            let group = SKAction.group([flipSequence, changeContentSequence])
            heart.run(SKAction.repeatForever(group))
        }
    }
    
    @objc func reduceTime() {
        progressBar?.xScale -= 0.1
    }
    
    
    func touchDown(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.green
            self.addChild(n)
        }
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.blue
            self.addChild(n)
        }
    }
    
    func touchUp(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.red
            self.addChild(n)
        }
    }
    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        if let label = self.label {
//            label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
//        }
//
//        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
//    }
//
//    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
//    }
//
//    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
//    }
//
//    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
//        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
//    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
