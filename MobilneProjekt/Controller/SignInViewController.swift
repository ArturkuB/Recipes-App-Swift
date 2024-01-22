import Foundation
import UIKit

class SignInViewController: UIViewController  {
   
    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var formView: UIStackView!
    
    let url = APIConfig.apiUrl
    
    var recipes: [Recipe] = []
    var tableView: UITableView!
    
    @objc func buttonAction(sender: UIButton!) {
        UserDefaults.standard.setValue("", forKey: "AuthToken")
        UserDefaults.standard.setValue(false, forKey: "SignedIn")
        
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        }
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginTextField.text = "artur@gmail.com"
        passwordTextField.text = "password"
        
    }
    
       
    @IBAction func LoginButtonPressed(_ sender: Any) {
        guard let email = loginTextField.text, let password = passwordTextField.text else {
            return
        }
        
        let parameters = ["email": email, "password": password]
        
        guard let url = URL(string: "\(url)/user/login") else {
        
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
                    if httpResponse.statusCode == 200 {
                        let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
                        print(json)
                        if let isAdmin = json?["admin"] as? Int {
 
                            UserDefaults.standard.setValue(isAdmin == 1, forKey: "isAdmin")
                        }
                        
                        if let userId = json?["userId"] as? String {
                            UserDefaults.standard.setValue(userId, forKey: "userId")
                        }

                        if let token = json?["token"] as? String {
                            print("Token: \(token)")
                            UserDefaults.standard.setValue(token, forKey: "AuthToken")
                            UserDefaults.standard.setValue(true, forKey: "SignedIn")
                            
                            DispatchQueue.main.async {
                                self.navigationController?.popViewController(animated: true)
                            }
                        } else {
                            print("Invalid response format")
                            Utilities().presentErrorAlert(message: "Invalid response!", duration: 2, viewController: self)
                        }
                    } else if httpResponse.statusCode == 401 {
                        Utilities().presentErrorAlert(message: "Authentication failed!", duration: 2, viewController: self)
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
