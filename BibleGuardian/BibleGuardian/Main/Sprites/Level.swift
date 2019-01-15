//
//  Level.swift
//  GameTest
//
//  Created by Avazu on 2019/1/2.
//  Copyright © 2019年 Ken. All rights reserved.
//

import Foundation

let numColumns = 8
let numRows = 8

class Level {
    
    private var words: [Word] = []
    var answerWords: [String] = [] {
        didSet {
            let temp = answerWords
            answerWords = []
            for word in temp {
                answerWords.append(word.uppercased())
            }
        }
    }
    var letters: [[Letter?]] = Array(repeating: Array(repeating: nil, count: numRows), count: numColumns)
    var letterSet: Set<Letter> = []
    
    func letter(atColumn column: Int, row: Int) -> Letter? {
        precondition(column >= 0 && column < numColumns)
        precondition(row >= 0 && row < numRows)
        return letters[column][row]
    }
    
    func buildLetters() {
        let coordinates = getCoordinates(words: answerWords.reversed())
        convertLetters(coordinates: coordinates)
    }
    
    func shuffle() -> Set<Letter> {
        let word0 = Word(column: 3, row: 2, word: "IS", isVerticle: true)
        let word1 = Word(column: 1, row: 0, word: "WHEN", isVerticle: false)
        let word2 = Word(column: 4, row: 3, word: "THAT", isVerticle: true)
        words.append(word2)
        words.append(word1)
        words.append(word0)
        return createInitialCookies()
    }
    
    func convertLetters(coordinates: [WordCoordinateStruct]) {
        letters = Array(repeating: Array(repeating: nil, count: numRows), count: numColumns)
        for co in coordinates {
            let letter = Letter(column: co.point.x, row: co.point.y, letter: LetterType(rawValue: co.name.uppercased())!)
            letters[co.point.x][co.point.y] = letter
        }
    }
    
    private func createInitialCookies() -> Set<Letter> {
//        var set: Set<Letter> = []
        
        for word in words {
            for (index, char) in word.word.enumerated() {
                var column = word.column
                var row = word.row
                if index != 0 {
                    if word.isVerticle {
                        row -= index
                        row = adjustPosition(column: column, row: row, adjustRow: true)
                    } else {
                        column += index
                        column = adjustPosition(column: column, row: row, adjustRow: false)
                    }
                }
                let letterType = LetterType(rawValue: String(char))!
                let letter = Letter(column: column, row: row, letter: letterType)
                letterSet.insert(letter)
                letters[column][row] = letter
            }
        }
//        // 1
//        for row in 0..<numRows {
//            for column in 0..<numColumns {
//
//                // 2
//                let letterType = LetterType(rawValue: "?")!
//
//                // 3
//                let letter = Letter(column: column, row: row, letter: letterType)
//                letters[column].append(letter)
//                
//                // 4
//                set.insert(letter)
//            }
//        }
        return letterSet
    }
    
    func adjustPosition(column: Int, row: Int, adjustRow: Bool) -> Int {
        var temp = 0
        if adjustRow {
            temp = row
        } else {
            temp = column
        }
        if !isPositionAvailable(column: column, row: row) {
            if adjustRow {
                temp -= 1
                temp = adjustPosition(column: column, row: temp, adjustRow: adjustRow)
            } else {
                temp += 1
                temp = adjustPosition(column: temp, row: row, adjustRow: adjustRow)
            }
        }
        return temp
    }
    
    func isPositionAvailable(column: Int, row: Int) -> Bool {
        for letter in letterSet {
            if letter.column == column && letter.row == row {
                return false
            }
        }
        return true
    }
    
    // 检测断开
    func checkBreak() -> [Int] {
        var startColumn: Int?
        var tempEmptyColumnArray: [Int] = []
        var breakColumns: [Int] = []
        
        // 横向遍历
        for (index, letterColumn) in letters.enumerated() {
            if startColumn == nil {
                // 未检测到开始列
                for letter in letterColumn {
                    if letter != nil {
                        startColumn = index
                        break
                    }
                }
            } else {
                // 检测到开始列
                var isEmpty = true
                for letter in letterColumn {
                    if letter != nil {
                        isEmpty = false
                        break
                    }
                }
                if isEmpty {
                    if tempEmptyColumnArray.count == 0 {
                        tempEmptyColumnArray.append(index)
                    } else {
                        if !tempEmptyColumnArray.contains(index - 1) {
                            breakColumns.append(contentsOf: tempEmptyColumnArray)
                            tempEmptyColumnArray.removeAll()
                            tempEmptyColumnArray.append(index)
                        } else {
                            tempEmptyColumnArray.append(index)
                        }
                    }
                }
            }
        }
        return breakColumns
    }
    
    func checkWordsAvailable() -> Bool {
        for columnLetters in letters {
            for letter in columnLetters {
                for word in answerWords {
                    if word.count <= 0 {
                        continue
                    }
                    // 找到首字母
                    if letter?.type.rawValue == String(word[0]) {
                        if word.count <= 1 {
                            continue
                        }
                        // 找到二字母
                        if letter!.row != 0 {
                            let verticle2ndLetter = letters[letter!.column][letter!.row - 1]
                            if verticle2ndLetter?.type.rawValue == String(word[1]) {
                                if findWord(word: word, in: letter!, inVerticle: true) {
                                    return true
                                }
                            }
                        }
                        if letter!.column < (numColumns - 1) {
                            let horizontal2ndLetter = letters[letter!.column + 1][letter!.row]
                            if horizontal2ndLetter?.type.rawValue == String(word[1]) {
                                if findWord(word: word, in: letter!, inVerticle: false) {
                                    return true
                                }
                            }
                        }
                    }
                }
            }
        }
        return false
    }
    
    // 检查第三及后续字母
    func findWord(word: String, in letter: Letter, inVerticle: Bool) -> Bool {
        var currentLetter: Letter!
        for i in 2 ... (word.count - 1) {
            if inVerticle {
                currentLetter = letters[letter.column][letter.row - i]
            } else {
                currentLetter = letters[letter.column + i][letter.row]
            }
            if currentLetter.type.rawValue != String(word[i]) {
                return false
            }
        }
        return true
    }
    
    func isWordBingo(word: String) -> Bool {
        for (index, answerWord) in answerWords.enumerated() {
            if word == answerWord.uppercased() {
                answerWords.remove(at: index)
                return true
            }
        }
        return false
    }
    
    // 构建
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
        let needRefreshX: Range = contentX..<(characters.count + contentX)
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
