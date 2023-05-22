//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Наиль on 22/05/23.
//

import Foundation
import UIKit

final class MovieQuizPresenter:QuestionFactoryDelegate {
    
    private weak var viewController: MovieQuizViewController?
    
    private let questionsAmount: Int = 10 //количество вопросов
    private var questionFactory: QuestionFactoryProtocol? //фабрика вопросов
    
    private var currentQuestionIndex = 0 //индекс текущего вопроса
    private var currentQuestion: QuizQuestion? //текущий вопрос
    
    var correctAnswers = 0//количество правильных ответов в текущем раунде
    
    private let statisticService: StatisticService!
    
    init(viewController: MovieQuizViewController) {
        
        statisticService = StatisticServiceImplementation()
        
        self.viewController = viewController
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
    }
    
    // MARK: - QuestionFactoryDelegate
    
    //данные о фильмах загружены
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    //произошла ошибка при загрузке данных о фильмах
    func didFailToLoadData(with error: Error) {
        viewController?.showNetworkError(message: error.localizedDescription)
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
    
    func restartGame() {//рестарт игры/новый раунд
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }
    
    func restartLoadData() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.loadData()
    }
    
    func isLastQuestion() -> Bool {//текуший вопрос яв-ся последним?
        currentQuestionIndex == questionsAmount - 1
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
       proceedWithAnswer(isCorrect: currentQuestion.correctAnswer == isYes)
    }
    
    //проверили правильность ответа
   func checkedAnswer(isCorrectAnswer: Bool) {
       if isCorrectAnswer {
           correctAnswers += 1
       }
    }
    
    //логика перехода в один из сценариев: 1) завершить игру 2) продолжить игру
    private func proceedToNextQuestionOrResults() {
       
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
    
    //метод, который обрабатывает результат ответа: красный или зеленый ободок
    private func proceedWithAnswer(isCorrect: Bool) {
        
        checkedAnswer(isCorrectAnswer: isCorrect)
        
        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
       
        // запускаем задачу "Показ следующего вопроса" через 1 секунду c помощью диспетчера задач
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.proceedToNextQuestionOrResults()
        }
    }
    
    //формируем текст с данными статистики из кеша
    func makeStatisticMessage () -> String {
        
        //обновляем данные в кеше
        statisticService.store(correct: self.correctAnswers, total: self.questionsAmount)
        
        let gameRecord = statisticService.bestGame
        let gamesCount = statisticService.gamesCount
        let totalAccuracy = statisticService.totalAccuracy
        
        //результат рекордной игры
        let textRecord = "\nРекорд: \(gameRecord.correct)/\(gameRecord.total) (\(gameRecord.date.dateTimeString))"
        
        //количество сыгранных квизов
        let textGamesCount = "\nКоличество сыгранных квизов: \(gamesCount)"
        
        //средняя точность
        let textTotalAccuracy = "\nСредняя точность: \(String(format: "%.2f", totalAccuracy))%"
        
        return textGamesCount + textRecord + textTotalAccuracy
    }
}
