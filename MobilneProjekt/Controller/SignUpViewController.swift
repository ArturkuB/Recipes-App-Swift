//
//  SignUpViewController.swift
//  MobilneProjekt
//
//  Created by Artur Balcer on 07/01/2024.
//

import Foundation
import Foundation
import UIKit

class SignUpViewController: UIViewController  {
    
    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var formView: UIStackView!
    @IBOutlet weak var repeatpasswordTextField: UITextField!
    let url = APIConfig.apiUrl
    
    var recipes: [Recipe] = []
    var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginTextField.text = "artur@gmail.com"
        passwordTextField.text = "password"
        
    }
    
    // MARK: - UITableView Delegate
    
    @IBAction func LoginButtonPressed(_ sender: Any) {
        guard let email = loginTextField.text, let password = passwordTextField.text else {
            
            return
        }
        if passwordTextField.text != repeatpasswordTextField.text {
            Utilities().presentErrorAlert(message: "Passwords are different!", duration: 2, viewController: self)
            return
        }
        let parameters = ["email": email, "password": password]
        
        guard let url = URL(string: "\(url)/user/signup") else {
            print("invalid url")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let error {
            print("JSON serialization error: \(error)")
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                guard let httpResponse = response as? HTTPURLResponse else {
                    return
                }
                
                guard let data = data, error == nil else {
                    print("Network error: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                do {
                    if httpResponse.statusCode == 201 {
                        let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
                        print(json)
                        if let message = json?["message"] as? String {
                            if(message == "User created") {
                                DispatchQueue.main.async {
                                    self.navigationController?.popViewController(animated: true)
                                    Utilities().presentErrorAlert(message: "Account was created!", duration: 2, viewController: self)
                                }
                            }
    
                        } else {
                            print("Invalid response format")
                            Utilities().presentErrorAlert(message: "Invalid response!", duration: 2, viewController: self)
                        }
                    } else if httpResponse.statusCode == 401 {
                        Utilities().presentErrorAlert(message: "Authentication failed!", duration: 2, viewController: self)
                    } else if httpResponse.statusCode == 409 {
                        Utilities().presentErrorAlert(message: "Mail already exists!", duration: 2, viewController: self)
                    } else {
                        print("Unexpected HTTP status code: \(httpResponse.statusCode)")
                    }
                } catch let error {
                    print("JSON parsing error: \(error)")
                }
            }
        }
        
        task.resume()
    }
    
    
    
}
