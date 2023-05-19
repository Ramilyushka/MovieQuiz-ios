//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Наиль on 13/04/23.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    
    func didReceiveNextQuestion(question: QuizQuestion?) //получить следующий вопрос
    func didLoadDataFromServer() // сообщение об успешной загрузке
    func didFailToLoadData(with error: Error) // сообщение об ошибке загрузки
}
