//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Наиль on 13/04/23.
//

import UIKit

class AlertPresenter {
    
    func showAlert(controller: UIViewController, alertModel: AlertModel) {
        
        let alert = UIAlertController(title: alertModel.title, message: alertModel.message, preferredStyle: .alert)
        alert.view.accessibilityIdentifier = "Alert"
        
        let action = UIAlertAction(title: alertModel.buttonText, style: .default, handler: alertModel.completion)
        alert.addAction(action)
        
        controller.present(alert, animated: true, completion: nil)
    }
}
