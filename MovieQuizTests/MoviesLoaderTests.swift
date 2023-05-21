//
//  MoviesLoaderTests.swift
//  MovieQuizTests
//
//  Created by Наиль on 21/05/23.
//

import XCTest
@testable import MovieQuiz

///Тестовая версия сетевого клиента
struct StubNetworkClient: NetworkRouting {
    
    //тестовая ошибка
    enum TestError: Error {
        case test
    }
    
    let emulateError: Bool //для эмуляции: true - ошибкa, false - успех
    
    func fetch (url: URL, handler: @escaping (Result<Data, Error>) -> Void ) {
        if emulateError {
            handler(.failure(TestError.test))
        } else {
            handler(.success(expectedResponse))
        }
    }
    
    //тестовый ответ от сервера
    private var expectedResponse: Data {
        """
        {
            "errorMessage" : "",
            "items" : [
               {
                  "crew" : "Dan Trachtenberg (dir.), Amber Midthunder, Dakota Beavers",
                  "fullTitle" : "Prey (2022)",
                  "id" : "tt11866324",
                  "imDbRating" : "7.2",
                  "imDbRatingCount" : "93332",
                  "image" : "https://m.media-amazon.com/images/M/MV5BMDBlMDYxMDktOTUxMS00MjcxLWE2YjQtNjNhMjNmN2Y3ZDA1XkEyXkFqcGdeQXVyMTM1MTE1NDMx._V1_Ratio0.6716_AL_.jpg",
                  "rank" : "1",
                  "rankUpDown" : "+23",
                  "title" : "Prey",
                  "year" : "2022"
               },
               {
                  "crew" : "Anthony Russo (dir.), Ryan Gosling, Chris Evans",
                  "fullTitle" : "The Gray Man (2022)",
                  "id" : "tt1649418",
                  "imDbRating" : "6.5",
                  "imDbRatingCount" : "132890",
                  "image" : "https://m.media-amazon.com/images/M/MV5BOWY4MmFiY2QtMzE1YS00NTg1LWIwOTQtYTI4ZGUzNWIxNTVmXkEyXkFqcGdeQXVyODk4OTc3MTY@._V1_Ratio0.6716_AL_.jpg",
                  "rank" : "2",
                  "rankUpDown" : "-1",
                  "title" : "The Gray Man",
                  "year" : "2022"
               }
             ]
           }
        """.data(using: .utf8) ?? Data()
    }
}

///Unit-tests для загрузки данных о фильмах
class MoviesLoaderTests: XCTestCase {
    
    //позитивный кейс: успешная загрузка данных
    func testSuccessLoading() throws {
        //Given
        let stubNetworkClient = StubNetworkClient(emulateError: false)
        let loader = MoviesLoader(networkClient: stubNetworkClient)
        
        //When
        //нужно ожидание
        let expectation = expectation(description: "Loading expectation")
        
        loader.loadMovies { result in
            //Then
            switch result {
                
            case .success(let movies):
                //сравниваем данные с ожидаемыми
                XCTAssertEqual(movies.items.count, 2)
                expectation.fulfill()
                
            case .failure(_):
                //проваливаем тест, если произошла ошибка
                XCTFail("Unexpected Failure")
            }
        }
        
        waitForExpectations(timeout: 1)
    }
    
    //негативный кейс: ошибка при загрузке данных
    func testFailLoading() throws {
        //Given
        let stubNetworkClient = StubNetworkClient(emulateError: true)
        let loader = MoviesLoader(networkClient: stubNetworkClient)
        
        //When
        //нужно ожидание
        let expectation = expectation(description: "Loading expectation")
        
        loader.loadMovies { result in
            //Then
            switch result {
                
            case .failure(let error):
                //сравниваем данные с ожидаемыми
                XCTAssertNotNil(error)
                expectation.fulfill()
                
            case .success(_):
                //проваливаем тест, если произошла ошибка
                XCTFail("Unexpected Failure")
            }
        }
        waitForExpectations(timeout: 1)
    }
}
