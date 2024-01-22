import Foundation
import UIKit
import Alamofire

class TableViewCell: UITableViewCell {
   
    @IBOutlet weak var firstImageView: UIImageView!
    
    @IBOutlet weak var cookingTimeLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var servingsLabel: UILabel!
}

class MyRecipesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate  {
        
    let apiUrl = APIConfig.apiUrl
    
    var myRecipes: [Recipe] = []
        
    @IBOutlet var tableView: UITableView!
    
     override func viewWillAppear(_ animated: Bool) {
        if let cachedRecipes = RecipeCacheManager.shared.loadRecipes() {
            var recipes: [Recipe] = []
            recipes = cachedRecipes
            if let userId = UserDefaults.standard.string(forKey: "userId") {
                for recipe in cachedRecipes {
                    if recipe.userId == userId {
                        myRecipes.append(recipe)
                    }
                }
            }
            self.tableView.reloadData()
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
            tableView.rowHeight = 100
            tableView.dataSource = self
            tableView.delegate = self
        }
        
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completionHandler) in
        
            let isAdmin = UserDefaults.standard.bool(forKey: "isAdmin")
            print(isAdmin)
            if isAdmin == true {
                self.deleteRecipe(recipeId: self.myRecipes[indexPath.row]._id) { (result) -> () in
                    if(result == true) {
                        self.myRecipes.remove(at: indexPath.row)
                        
                        RecipeCacheManager.shared.saveRecipes(self.myRecipes)
                        
                        tableView.deleteRows(at: [indexPath], with: .automatic)
                        print(indexPath.row)
                        
                        completionHandler(true)
                    }
                    
                }
            }
            else
            {
                Utilities().presentErrorAlert(message: "You don't have permission to do that!", duration: 3, viewController: self)
            }
        }
        
        let swipeConfiguration = UISwipeActionsConfiguration(actions: [deleteAction])
        return swipeConfiguration
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myRecipes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableViewCell
        let recipe = myRecipes[indexPath.row]
        cell.titleLabel.text = recipe.name
        cell.servingsLabel.text = "Porcje: " + String(recipe.servings)
        cell.cookingTimeLabel.text = "Czas: " + String(recipe.cookingTime) + "s"
        
    
        if let imageUrl = URL(string: recipe.imageUrl ?? "") {
            cell.firstImageView.sd_setImage(with: imageUrl, completed: nil)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let recipe = myRecipes[indexPath.row]
        let detailViewController = self.storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        detailViewController.recipe = recipe
        self.present(detailViewController, animated: true, completion: nil)
    }
    
    func deleteRecipe(recipeId: String, completion: @escaping (Bool)->()) {
        guard let token = UserDefaults.standard.string(forKey: "AuthToken") else {
            print("Token JWT nie został znaleziony.")
            return
        }
       
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)"
        ]
        print(recipeId)
        AF.request("\(apiUrl)/recipes/\(recipeId)", method: .delete, headers: headers)
            .responseJSON { response in
                switch response.result {
                case .success(let data):
                    print("Raw response data: \(data)")
                    if let jsonData = data as? [String: Any] {
                        if let message = jsonData["message"] as? String {
                            print("Recipe deleted: \(message)")
                            completion(true)
                        }
                    }
                case .failure(let error):
                    print("Error deleting recipe: \(error)")
                    completion(false)
                }
            }
    }
    
    }
    
    

