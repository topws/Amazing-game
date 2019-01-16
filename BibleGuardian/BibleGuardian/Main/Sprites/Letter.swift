//
//  LetterBlock.swift
//  GameTest
//
//  Created by Avazu on 2019/1/2.
//  Copyright © 2019年 Ken. All rights reserved.
//

import SpriteKit

// MARK: - CookieType
enum LetterType: String {
    case unknown = "?", A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z
}

// MARK: - Cookie
class Letter: CustomStringConvertible, Hashable {
    
    var hashValue: Int {
        return row * 10 + column
    }
    
    static func == (lhs: Letter, rhs: Letter) -> Bool {
        return lhs.column == rhs.column && lhs.row == rhs.row && lhs.type == rhs.type
        
    }
    
    var description: String {
        return "type:\(type) sprite:\(String(describing: sprite)) square:(\(column),\(row))"
    }
    
    var isSelected: Bool = false {
        didSet {
            sprite?.color = isSelected ? UIColor.red : UIColor.clear
        }
    }
    var column: Int
    var row: Int
    let type: LetterType
    var sprite: SKSpriteNode?
    
    init(column: Int, row: Int, letter: LetterType) {
        self.column = column
        self.row = row
        self.type = letter
    }
}

