//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Наиль on 13/04/23.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    
    func didReceiveNextQuestion(question: QuizQuestion?)
}
