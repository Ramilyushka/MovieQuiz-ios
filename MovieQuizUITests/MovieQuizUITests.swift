//
//  MovieQuizUITests.swift
//  MovieQuizUITests
//
//  Created by Наиль on 22/05/23.
//

import XCTest

final class MovieQuizUITests: XCTestCase {
    
    var app: XCUIApplication!

    override func setUpWithError() throws {
        
        try super.setUpWithError()
        
        app = XCUIApplication()
        app.launch() // откроется приложение

        // если один тест не прошёл, то следующие тесты запускаться не будут
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        
        try super.tearDownWithError()
        
        app.terminate() //закроется приложение
        app = nil
    }
    
    //Тест нажатия кнопки ДА и смены постера
    func testYesButton() throws {
        
        sleep(3)
        
        let firstPoster = app.images["Poster"] //отобразился первый постер
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        
        app.buttons["Yes"].tap() //нажали кнопку ДА
        
        sleep(3)
        let secondPoster = app.images["Poster"] //отобразился второй постер
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        
 
        XCTAssertNotEqual(firstPosterData, secondPosterData) //проверили что содержимое скринштов разные
        
        let indexLabel = app.staticTexts["Index"]
        XCTAssertEqual(indexLabel.label, "2/10") //проверили что счетчик вопросов увеличился
    }
    
    //Тест нажатия кнопки НЕТ и смены постера
    func testNoButton() throws {
        
        sleep(3)
        
        let firstPoster = app.images["Poster"] //отобразился первый постер
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        
        app.buttons["No"].tap() //нажали кнопку НЕТ
        
        sleep(3)
        let secondPoster = app.images["Poster"] //отобразился второй постер
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        
 
        XCTAssertNotEqual(firstPosterData, secondPosterData) //проверили что содержимое скринштов разные
        
        let indexLabel = app.staticTexts["Index"]
        XCTAssertEqual(indexLabel.label, "2/10") //проверили что счетчик вопросов увеличился
    }
    
    //Тест отображения алерта с результатами в конце раунда
    func testAlertResultShow() throws {
        
        sleep(2)
        for _ in 1...10 { //проходим квиз: 10 раз нажали на кнопку ДА
            app.buttons["Yes"].tap()
            sleep(2)
        }
        
        let alertResult = app.alerts["Alert"]
        
        XCTAssertTrue(alertResult.exists) //отобразился алерт с результатами
        XCTAssertEqual(alertResult.label, "Этот раунд окончен!") //проверили текст заголовка
        XCTAssertEqual(alertResult.buttons.firstMatch.label, "Сыграть ещё раз") //проверили тест кнопки
    }
    
    //Тест закрытие алерта с результатами нажатием кнопки "Сыграть ещё раз"
    func testAlertResultClose() throws {
        
        sleep(2)
        for _ in 1...10 { //проходим квиз: 10 раз нажали на кнопку ДА
            app.buttons["Yes"].tap()
            sleep(2)
        }
        
        let alertResult = app.alerts["Alert"]
        
        XCTAssertTrue(alertResult.exists) //отобразился алерт с результатами
        
        alertResult.buttons.firstMatch.tap() //нажали на кнопку "Сыграть ещё раз"
        
        sleep(2)
        
        XCTAssertFalse(alertResult.exists) //закрылся алерт с результатами
        
        let indexLabel = app.staticTexts["Index"]
        XCTAssertEqual(indexLabel.label, "1/10") //проверили что счетчик вопросов обнулился
    }
}
