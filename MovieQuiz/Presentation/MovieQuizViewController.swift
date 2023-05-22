import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    // MARK: - Lifecycle
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var buttonsStackView: UIStackView!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
            .lightContent
        }
    
    private let presenter = MovieQuizPresenter()
    
    private var questionFactory: QuestionFactoryProtocol?
    
    private var correctAnswers = 0
    
    private var alertPresenter: AlertPresenter?
    
    private var statisticService: StatisticService?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.layer.cornerRadius = 20
        
        presenter.viewController = self
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        
        showLoadingIndicator()
        buttonsStackView.isUserInteractionEnabled = false //блокируем кнопки Да/Нет
        questionFactory?.loadData()
        
        alertPresenter = AlertPresenter()
        
        statisticService = StatisticServiceImplementation()
    }
    
    @IBAction private func yesButtonClicked(_ sender: Any) {
        presenter.yesButtonClicked()
    }
    
    @IBAction private func noButtonClicked(_ sender: Any) {
        presenter.noButtonClicked()
    }
    
    //отображение индикатора загрузки
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    //отображение алерта с ошибкой загрузки данных вначале
    private func showNetworkError(message: String) {
        
        activityIndicator.isHidden = true // скрываем индикатор загрузки
        
        let alertModel = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать ещё раз",
            completion: { [weak self] _ in
                guard let self = self else { return }
                
                self.presenter.resetQuesionIndex()
                self.correctAnswers = 0
                
                self.showLoadingIndicator()
                self.questionFactory?.loadData() //пробуем снова загрузить данные после ошибки
            })
        
        alertPresenter?.showAlert(controller: self, alertModel: alertModel)
    }
    
    // MARK: - QuestionFactoryDelegate
    
    //вопрос готов к показу
    func didReceiveNextQuestion(question: QuizQuestion?) {
        
        presenter.didReceiveNextQuestion(question: question)
    }
    
    //данные о фильмах загружены
    func didLoadDataFromServer() {
        activityIndicator.isHidden = true
        questionFactory?.requestNextQuestion()
    }
    
    //произошла ошибка при загрузке данных о фильмах
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
    //метод вывода на экран вопроса
    func showQuestion(quiz step: QuizStepViewModel) {
        
        imageView.image = step.image
        imageView.layer.borderWidth = 0 //убираем ободок
        
        textLabel.text = step.quiestion
        counterLabel.text = step.questionNumber
        
        buttonsStackView.isUserInteractionEnabled = true //РАЗблокируем кнопки Да/Нет
    }
    
    //метод, который обрабатывает результат ответа: красный или зеленый ободок
    func showAnswerResult(isCorrect: Bool) {
        
        buttonsStackView.isUserInteractionEnabled = false //блокируем кнопки Да/Нет
        
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
            self.presenter.correctAnswers = self.correctAnswers
            self.presenter.questionFactory = self.questionFactory
            self.presenter.showNextQuestionOrResults()
        }
    }
    
    //метод для показа Алерта результатов раунда квиза
    func showQuizResultAlert(quiz result: QuizResultsViewModel) {
        
        let message = result.text + getStatisticResult()
        
        let alertModel = AlertModel(
            title: result.title,
            message: message,
            buttonText: result.buttonText,
            completion: { [weak self] _ in
                guard let self = self else { return }
                
                self.presenter.resetQuesionIndex()
                self.correctAnswers = 0
                
                self.questionFactory?.requestNextQuestion()
            })
        
        alertPresenter?.showAlert(controller: self, alertModel: alertModel)
    }
    
    //формируем текст с данными статистики из кеша
    func getStatisticResult () -> String {
        
        //обновляем данные в кеше
        statisticService?.store(correct: correctAnswers, total: presenter.questionsAmount)
        
        guard
            let gameRecord = statisticService?.bestGame,
            let gamesCount = statisticService?.gamesCount,
            let totalAccuracy = statisticService?.totalAccuracy
        else { return "\nНевозможно загрузить данные статистики" }
        
        //результат рекордной игры
        let textRecord = "\nРекорд: \(gameRecord.correct)/\(gameRecord.total) (\(gameRecord.date.dateTimeString))"
        
        //количество сыгранных квизов
        let textGamesCount = "\nКоличество сыгранных квизов: \(gamesCount)"
        
        //средняя точность
        let textTotalAccuracy = "\nСредняя точность: \(String(format: "%.2f", totalAccuracy))%"
        
        return textGamesCount + textRecord + textTotalAccuracy
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
