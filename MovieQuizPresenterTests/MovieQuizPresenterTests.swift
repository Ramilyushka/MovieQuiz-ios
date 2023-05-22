//
//  MovieQuizPresenterTests.swift
//  MovieQuizPresenterTests
//
//  Created by Наиль on 23/05/23.
//

import XCTest
@testable import MovieQuiz

final class MovieQuizViewControllerMock: MovieQuizViewControllerProtocol {
    func showQuestion(quiz step: QuizStepViewModel) {
    
    }
    
    func showQuizResultAlert(quiz result: QuizResultsViewModel) {
    
    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
    
    }
    
    func showLoadingIndicator() {
    
    }
    
    func hideLoadingIndicator() {
    
    }
    
    func showNetworkError(message: String) {
    
    }
}

final class MovieQuizPresenterTests: XCTestCase {

    func testPresenterConvertModel() throws {
        
        let viewControllerMock: MovieQuizViewControllerProtocol = MovieQuizViewControllerMock()
        let presenter = MovieQuizPresenter(viewController: viewControllerMock)
        
        let emptyData = Data()
        let question = QuizQuestion(image: emptyData, text: "Рейтинг этого фильма больше чем 7?", correctAnswer: true)
        let viewModel = presenter.convertQuestion(model: question)
        
        XCTAssertNotNil(viewModel.image)
        XCTAssertEqual(viewModel.quiestion, "Рейтинг этого фильма больше чем 7?")
        XCTAssertEqual(viewModel.questionNumber, "1/10")
    }
}
