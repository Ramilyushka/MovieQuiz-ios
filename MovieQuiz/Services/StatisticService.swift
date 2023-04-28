//  StatisticService.swift
//  MovieQuiz

import Foundation

protocol StatisticService {

    var totalAccuracy: Double { get }
    var gamesCount: Int { get }
    var bestGame: GameRecord { get }
    
    func store(correct count: Int, total amount: Int)
}

final class StatisticServiceImplementation: StatisticService {
    
    private let userDefaults = UserDefaults.standard
    
    private enum Keys: String {
        case totalCorrect, totalAnswers, bestGame, gamesCount
    }
    
    //общее количество правильных ответов
    private var totalCorrect: Int {
        get {
            let recordTotalCorrect = userDefaults.integer(forKey: Keys.totalCorrect.rawValue)
            return recordTotalCorrect
        }
        set {
            userDefaults.set(newValue, forKey: Keys.totalCorrect.rawValue)
        }
    }
    
    //общее количество вопросов
    private var totalAnswers: Int {
        get {
            let recordTotalAnswers = userDefaults.integer(forKey: Keys.totalAnswers.rawValue)
            return recordTotalAnswers
        }
        set {
            userDefaults.set(newValue, forKey: Keys.totalAnswers.rawValue)
        }
    }
    
    //средняя точность
    var totalAccuracy: Double {
        get {
            return (Double(totalCorrect) / Double(totalAnswers) * 100.0)
        }
    }

    //количество игр
    var gamesCount: Int {
        get {
            let recordGamesCount = userDefaults.integer(forKey: Keys.gamesCount.rawValue)
            return recordGamesCount
        }
        set {
            userDefaults.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
                                      
    //результаты рекордной (лучшей) игры
    var bestGame: GameRecord {
        get {
            guard let data = userDefaults.data(forKey: Keys.bestGame.rawValue),
                let recordBestGame = try? JSONDecoder().decode(GameRecord.self, from: data) else {
                return .init(correct: 0, total: 0, date: Date())
            }
            return recordBestGame
        }
        
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                //print("Невозможно сохранить результат")
                return
            }
            userDefaults.set(data, forKey: Keys.bestGame.rawValue)
        }
    }
    
    ///обновляем данные в кеше
    func store(correct count: Int, total amount: Int) {
        
        let currentGame = GameRecord(correct: count, total: amount, date: Date())
        
        //если текущая игра лучше, то обновляем данные в кеше
        if currentGame > bestGame {
            bestGame = GameRecord(correct: count, total: amount, date: Date())
        }
        
        gamesCount += 1
        
        totalCorrect += count
        totalAnswers += amount
    }
}
