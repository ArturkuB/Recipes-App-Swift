import Foundation
import UIKit
import Alamofire


class AccountViewController: UIViewController {
    
    let apiUrl = APIConfig.apiUrl
    
    var myRecipes: [Recipe] = []
    
    
    @IBAction func logOutButtonPressed(_ sender: Any) {
        UserDefaults.standard.setValue("", forKey: "AuthToken")
        UserDefaults.standard.setValue(false, forKey: "SignedIn")
        
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        }
        
    }
    
    
}



