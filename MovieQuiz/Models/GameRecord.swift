//
//  GameRecord.swift
//  MovieQuiz
//
//  Created by Наиль on 26/04/23.
//

import Foundation

struct GameRecord: Codable, Comparable {
    let correct: Int
    let total: Int
    let date: Date
    
    static func > (current: GameRecord, old: GameRecord) -> Bool {
        return current.correct >= old.correct
    }
    
    static func < (lhs: GameRecord, rhs: GameRecord) -> Bool {
        return lhs.correct < rhs.correct
    }
}
