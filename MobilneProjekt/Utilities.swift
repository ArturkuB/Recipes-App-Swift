//
//  Utilities.swift
//  MobilneProjekt
//
//  Created by Artur Balcer on 23/12/2023.
//

import Foundation
import UIKit

class Utilities {
    
    func presentErrorAlert(message: String, duration: Double = 2.0, viewController: UIViewController) {
        let dialogMessage = UIAlertController(title: "Attention", message: message, preferredStyle: .alert)
        
        viewController.present(dialogMessage, animated: true, completion: nil)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            dialogMessage.dismiss(animated: true, completion: nil)
        }
    }
    
}
