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
        let coordinates = WordArrangement.manager.getCoordinates(words: answerWords.reversed())
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
	
}
