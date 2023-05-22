//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Наиль on 22/05/23.
//

import Foundation
import UIKit

final class MovieQuizPresenter {
    
    weak var viewController: MovieQuizViewController?
    
    let questionsAmount: Int = 10 //количество вопросов
    
    private var currentQuestionIndex = 0 //индекс текущего вопроса
   var currentQuestion: QuizQuestion? //текущий вопрос
    
    
    func isLastQuestion() -> Bool {//текуший вопрос яв-ся последним?
        currentQuestionIndex == questionsAmount - 1
    }
    
    func resetQuesionIndex() {//обнуляем индекс текущего вопроса
        currentQuestionIndex = 0
    }
    
    func switchToNextQuestion() {//увеличиваем индекс текущего вопроса
        currentQuestionIndex += 1
    }
    
    //конвертация модели вопроса во вью модель вопроса для экрана
    func convertQuestion(model: QuizQuestion) -> QuizStepViewModel {
        
        let questionStep = QuizStepViewModel (
            image: UIImage(data: model.image) ?? UIImage(),
            quiestion: model.text,
            questionNumber: "\(currentQuestionIndex+1)/\(questionsAmount)" )
        
        return questionStep
    }
    
    func yesButtonClicked() {
        
        guard let currentQuestion = currentQuestion else { return }
        viewController?.showAnswerResult(isCorrect: currentQuestion.correctAnswer == true)
    }
    
    func noButtonClicked() {
        
        guard let currentQuestion = currentQuestion else { return }
        viewController?.showAnswerResult(isCorrect: currentQuestion.correctAnswer == false)
    }
}
