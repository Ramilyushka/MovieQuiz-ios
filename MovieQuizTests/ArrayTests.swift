//
//  ArrayTests.swift
//  MovieQuizTests
//
//  Created by Наиль on 21/05/23.
//

import XCTest
@testable import MovieQuiz

class ArrayTest: XCTestCase {
    
    //позитивный кейс: берем элемент по правильному индексу
    func testGetValueInRange() throws {
        //Given
        let array = [1, 1, 2, 3, 5]
        
        //When
        let value = array[safe: 2]
        
        //Then
        XCTAssertNotNil(value)
        XCTAssertEqual(value, 2)
    }
    
    //негативный кейс: берем элемент по НЕправильному индексу
    func testGetValueOutOfRange () throws {
        //Given
        let array = [1, 1, 2, 3, 5]
        
        //When
        let value = array[safe: 20]
        
        //Then
        XCTAssertNil(value)
    }
}
