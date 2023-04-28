import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    // MARK: - Lifecycle
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!

    
    @IBOutlet private var buttonsStackView: UIStackView!
    
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    
    private var currentQuestionIndex = 0
    private var currentQuestion: QuizQuestion?
    
    private var correctAnswers = 0
    
    private var alertPresenter: AlertPresenter?
    
    private var statisticService: StatisticService?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.layer.cornerRadius = 20
        
        questionFactory = QuestionFactory(delegate: self)
        questionFactory?.requestNextQuestion()
        
        alertPresenter = AlertPresenter()
        
        statisticService = StatisticServiceImplementation()
    }
    
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else { return }
        
        currentQuestion = question
        let viewModel = convertQuestion(model: question)
        
        DispatchQueue.main.async { [weak self] in
              self?.showQuestion(quiz: viewModel)
          }
    }
    
    //метод конвертации, который принимает моковый вопрос и возвращает вью модель для экрана вопроса
    private func convertQuestion(model: QuizQuestion) -> QuizStepViewModel {
        
        let questionStep = QuizStepViewModel (
            image: UIImage(named: model.image) ?? UIImage(),
            quiestion: model.text,
            questionNumber: "\(currentQuestionIndex+1) /\(questionsAmount)" )
        
        return questionStep
    }
    
    // метод вывода на экран вопроса
    private func showQuestion(quiz step: QuizStepViewModel) {
        
        imageView.image = step.image
        imageView.layer.borderWidth = 0
        
        textLabel.text = step.quiestion
        counterLabel.text = step.questionNumber
        
        buttonsStackView.isUserInteractionEnabled = true
    }
    
    //метод, который обрабатывает результат ответа
    private func showAnswerResult(isCorrect: Bool) {
        
        buttonsStackView.isUserInteractionEnabled = false
        
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        
        var color = UIColor.ypRed.cgColor
        if isCorrect {
            color = UIColor.ypGreen.cgColor
            correctAnswers += 1
        }
        
        imageView.layer.borderColor = color
        
        // запускаем задачу "Показ следующего вопроса" через 1 секунду c помощью диспетчера задач
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.showNextQuestionOrResults()
        }
    }
    
    //метод для показа Алерта результатов раунда квиза
    private func showQuizResultAlert(quiz result: QuizResultsViewModel) {
        
        let alertModel = AlertModel(
            title: result.title,
            message: result.text,
            buttonText: result.buttonText,
            completion: { [weak self] _ in
                guard let self = self else { return }
                
                self.currentQuestionIndex = 0
                self.correctAnswers = 0
                
                self.questionFactory?.requestNextQuestion()
            })
        
        alertPresenter?.showAlert(controller: self, alertModel: alertModel)
    }
    
    //метод для обновляем данные в кеше
    private func updateTotalResult () -> String {
        
        statisticService?.store(correct: correctAnswers, total: questionsAmount)
        
        guard
            let gameRecord = statisticService?.bestGame,
            let gamesCount = statisticService?.gamesCount,
            let totalAccuracy = statisticService?.totalAccuracy
        else { return "\nНевозможно загрузить данные статистики" }
        
        //результат рекордной игры
        let textRecord = "\nРекорд:\(gameRecord.correct)/\(gameRecord.total) (\(gameRecord.date.dateTimeString))"
        
        //количество сыгранных квизов
        let textGamesCount = "\nКоличество сыгранных квизов: \(gamesCount)"
        
        //средняя точность
        let textTotalAccuracy = "\nСредняя точность: \(String(format: "%.2f", totalAccuracy))"
        
        return textGamesCount + textRecord + textTotalAccuracy
    }
    
    //метод, который содержит логику перехода в один из сценариев: 1) завершить игру 2) продолжить игру
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            
            //результат текущей игры
            let textCurrentResult = correctAnswers == questionsAmount ?
            "Поздравляем, Вы ответили на \(questionsAmount) из \(questionsAmount)!" :
            "Ваш результат: \(correctAnswers) /\(questionsAmount)"
            
            let textAllResult = textCurrentResult + updateTotalResult()

            let viewQuizResultModel = QuizResultsViewModel(
                        title: "Этот раунд окончен!",
                        text: textAllResult,
                        buttonText: "Сыграть ещё раз")
            
            showQuizResultAlert(quiz: viewQuizResultModel)
            
        } else {
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
        }
    }
    
    @IBAction private func yesButtonClicked(_ sender: Any) {
        
        guard let currentQuestion = currentQuestion else { return }
        showAnswerResult(isCorrect: currentQuestion.correctAnswer == true)
    }
    
    @IBAction private func noButtonClicked(_ sender: Any) {
        
        guard let currentQuestion = currentQuestion else { return }
        showAnswerResult(isCorrect: currentQuestion.correctAnswer == false)
    }
    
}

/*
 Mock-данные
 
 
 Картинка: The Godfather
 Настоящий рейтинг: 9,2
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: The Dark Knight
 Настоящий рейтинг: 9
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: Kill Bill
 Настоящий рейтинг: 8,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: The Avengers
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: Deadpool
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: The Green Knight
 Настоящий рейтинг: 6,6
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: Old
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ


 Картинка: The Ice Age Adventures of Buck Wild
 Настоящий рейтинг: 4,3
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ


 Картинка: Tesla
 Настоящий рейтинг: 5,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ


 Картинка: Vivarium
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 */
