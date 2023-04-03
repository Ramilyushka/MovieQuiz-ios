import UIKit

final class MovieQuizViewController: UIViewController {
    // MARK: - Lifecycle
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!

    
    @IBOutlet private var buttonsStackView: UIStackView!
    
    private struct QuizQuestion {
        let image: String
        let text: String
        let correctAnswer: Bool
    }
    
    private struct QuizStepViewModel {
        let image: UIImage
        let quiestion: String
        let questionNumber: String
    }
    
    private struct QuizResultsViewModel {
      let title: String
      let text: String
      let buttonText: String
    }
    
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    
    private let questions: [QuizQuestion] = [
        QuizQuestion (image: "The Godfather", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion (image: "The Dark Knight", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion (image: "Kill Bill", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion (image: "The Avengers", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion (image: "Deadpool", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion (image: "The Green Knight", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion (image: "Old", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
        QuizQuestion (image: "The Ice Age Adventures of Buck Wild", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
        QuizQuestion (image: "Tesla", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
        QuizQuestion (image: "Vivarium", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false)
    ]
    
    
    //метод конвертации, который принимает моковый вопрос и возвращает вью модель для экрана вопроса
    private func convertQuestion(model: QuizQuestion) -> QuizStepViewModel {
        
        let questionStep = QuizStepViewModel (
            image: UIImage(named: model.image) ?? UIImage(),
            quiestion: model.text,
            questionNumber: "\(currentQuestionIndex+1) /\(questions.count)" )
        
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
    
    // метод для показа результатов раунда квиза
    private func showResultQuiz(quiz result: QuizResultsViewModel) {
        
        let alert = UIAlertController(
            title: result.title,
            message: result.text,
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: result.buttonText, style: .default) { _ in
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            let firstQuestion = self.questions[self.currentQuestionIndex] // 2
            let viewModel = self.convertQuestion(model: firstQuestion)
            self.showQuestion(quiz: viewModel)
        }
        
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    //метод, который содержит логику перехода в один из сценариев
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questions.count - 1 {
            
            let rezultQuiz = QuizResultsViewModel (
                title: "Этот раунд окончен!",
                text: "Ваш результат: \(correctAnswers) /\(questions.count)",
                buttonText: "Сыграть ещё раз")
            
            showResultQuiz(quiz: rezultQuiz)

        } else {
            currentQuestionIndex += 1
            let nextQuestion = questions[currentQuestionIndex]
            let nextQuizStep = convertQuestion(model: nextQuestion)
            showQuestion(quiz: nextQuizStep)
        }
        
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
        
        // запускаем задачу через 1 секунду c помощью диспетчера задач
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [self] in
           showNextQuestionOrResults()
        }
    }
    
    @IBAction private func yesButtonClicked(_ sender: Any) {
        if currentQuestionIndex < questions.count {
            
            let currentQuestion = questions[currentQuestionIndex]
            showAnswerResult(isCorrect: currentQuestion.correctAnswer == true)
        }
    }
    
    @IBAction private func noButtonClicked(_ sender: Any) {
        if currentQuestionIndex < questions.count {
            
            let currentQuestion = questions[currentQuestionIndex]
            showAnswerResult(isCorrect: currentQuestion.correctAnswer == false)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.layer.cornerRadius = 20
        
        let startQuestion = questions[0]
        let startQuizStepViewModel = convertQuestion(model: startQuestion)
        showQuestion(quiz: startQuizStepViewModel)
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
