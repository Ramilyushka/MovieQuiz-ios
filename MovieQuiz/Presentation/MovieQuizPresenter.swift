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
    var questionFactory: QuestionFactoryProtocol? //фабрика вопросов
    
    private var currentQuestionIndex = 0 //индекс текущего вопроса
    var currentQuestion: QuizQuestion? //текущий вопрос
    
    var correctAnswers = 0//количество правильных ответов в текущем раунде
    
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
        
        didAnswer(isYes: true)
    }
    
    func noButtonClicked() {
        
        didAnswer(isYes: false)
    }
    
    //получили ответ ДА/НЕТ
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else { return }
        viewController?.showAnswerResult(isCorrect: currentQuestion.correctAnswer == isYes)
    }
    
    //вопрос готов к показу
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else { return }
        
        currentQuestion = question
        let viewModel = convertQuestion(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.showQuestion(quiz: viewModel)
          }
    }
    
    //логика перехода в один из сценариев: 1) завершить игру 2) продолжить игру
    func showNextQuestionOrResults() {
       
        if self.isLastQuestion() {
            
            //текст результата текущей игры
            let text = correctAnswers == self.questionsAmount ?
            "Поздравляем, Вы ответили на \(correctAnswers) из \(self.questionsAmount)!" :
            "Ваш результат: \(correctAnswers)/\(self.questionsAmount)"

            let viewQuizResultModel = QuizResultsViewModel(
                        title: "Этот раунд окончен!",
                        text: text,
                        buttonText: "Сыграть ещё раз")
            
            viewController?.showQuizResultAlert(quiz: viewQuizResultModel)
            
        } else {
            self.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
}
