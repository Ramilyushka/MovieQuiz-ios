//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Наиль on 13/04/23.
//

import UIKit

class AlertPresenter {
    
//    weak var delegate: AlertPresenterDelegate?
//
//    init(delegate: AlertPresenterDelegate?) {
//        self.delegate = delegate
//    }
    
    func showAlert(controller: UIViewController, alertModel: AlertModel) {
        
        let alert = UIAlertController(title: alertModel.title, message: alertModel.message, preferredStyle: .alert)
        
        let action = UIAlertAction(title: alertModel.buttonText, style: .default, handler: alertModel.completion)
        alert.addAction(action)
        
        controller.present(alert, animated: true, completion: nil)
    }
}
