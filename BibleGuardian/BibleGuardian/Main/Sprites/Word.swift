//
//  Word.swift
//  GameTest
//
//  Created by Avazu on 2019/1/2.
//  Copyright © 2019年 Ken. All rights reserved.
//

import Foundation

class Word: CustomStringConvertible, Hashable {
    
    var hashValue: Int {
        return row * 10 + column
    }
    
    static func == (lhs: Word, rhs: Word) -> Bool {
        return lhs.column == rhs.column && lhs.row == rhs.row
        
    }
    
    var description: String {
        return "square:(\(column),\(row))"
    }
    
    var column: Int
    var row: Int
    var word: String
    var isVerticle: Bool
    
    init(column: Int, row: Int, word: String, isVerticle: Bool) {
        self.column = column
        self.row = row
        self.word = word
        self.isVerticle = isVerticle
    }
}
