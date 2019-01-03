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
    var answerWords = ["THAT", "IS", "WHEN"]
    var letters: [[Letter?]] = Array(repeating: Array(repeating: nil, count: numRows), count: numColumns)
    var letterSet: Set<Letter> = []
    
    func letter(atColumn column: Int, row: Int) -> Letter? {
        precondition(column >= 0 && column < numColumns)
        precondition(row >= 0 && row < numRows)
        return letters[column][row]
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
    
    func isWordBingo(word: String) -> Bool {
        for (index, answerWord) in answerWords.enumerated() {
            if word == answerWord.uppercased() {
                answerWords.remove(at: index)
                return true
            }
        }
        return false
    }
    
//    func findCross(word0: Word, word1: Word) -> (Int, Int)? {
//        if !word0.isVerticle {
//            var temp = word0.isVerticle ? word0.row : word0.column
//            let lastColumn1 = word1.column + (word1.isVerticle ? 0 : word1.word.count)
//            for column0 in temp ..< (temp + word0.word.count) {
//                for column1 in word1.column ..< lastColumn1 {
//                    if column0 == column1 {
//
//                    }
//                }
//            }
//        }
//        return (0, 0)
//    }
}
