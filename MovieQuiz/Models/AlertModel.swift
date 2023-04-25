//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Наиль on 13/04/23.
//

import Foundation
import UIKit

struct AlertModel {
    let title: String
    let message: String
    let buttonText: String
    var completion: ((UIAlertAction) -> Void)?
//    let action = UIAlertAction() { [weak self] _ in
//        guard let self = self else { return }
}
