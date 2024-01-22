import UIKit
import Alamofire
import SDWebImage
import DropDown

class ItemTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var firstImageView: UIImageView!
    @IBOutlet weak var servingsLabel: UILabel!
    @IBOutlet weak var cookingTimeLabel: UILabel!
}


class ListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var dotsButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    var dropDown = DropDown()
    
    var recipes: [Recipe] = []
    var loggedIn: Bool = false
     
    let apiUrl = "\(APIConfig.apiUrl)/recipes"
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
       
        if let cachedRecipes = RecipeCacheManager.shared.loadRecipes() {
            self.recipes = cachedRecipes
            self.tableView.reloadData()
        }
        
    
        if let url = URL(string: apiUrl) {
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let data = data {
                    do {
                        let decoder = JSONDecoder()
                        let decodedData = try decoder.decode(RecipeResponse.self, from: data)
                        self.recipes = decodedData.recipes
                        
                
                        RecipeCacheManager.shared.saveRecipes(self.recipes)
                
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    } catch {
                        print("Błąd dekodowania danych JSON: \(error)")
                    }
                }
            }.resume()
        }
        print(self.recipes)
        if UserDefaults.standard.bool(forKey: "SignedIn") {
            print("Zalogowany!")
            dropDown.dataSource = ["Account", "My recipes"]
            dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
                print("Selected item: \(item) at index: \(index)")
                switch item {
                case "Account":
                    self.performSegue(withIdentifier: "accountSegue", sender: nil)
                    break
                case "My recipes":
                    self.performSegue(withIdentifier: "myRecipesSegue", sender: nil)
                default:
                    break
                }
            }
        }
        else {
            print("Niezalogowany!")
            dropDown.dataSource = ["Sign In", "Sign Up"]
            dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
                switch item {
                case "Sign In":
                    self.performSegue(withIdentifier: "signInSegue", sender: nil)
                    break
                case "Sign Up":
                    self.performSegue(withIdentifier: "signUpSegue", sender: nil)
                default:
                    break
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 100
        

        dropDown.anchorView = dotsButton
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    @IBAction func signButtonPressed(_ sender: Any) {
        dropDown.show()
    }
    
    @IBAction func addRecipeButtonPressed(_ sender: Any) {
        if UserDefaults.standard.bool(forKey: "SignedIn") {
            performSegue(withIdentifier: "addRecipeSegue", sender: nil)
        }
        else
        {
            Utilities().presentErrorAlert(message: "Sign In first!", duration: 2, viewController: self)
        }
    }
    
    // MARK: SwipeLeft Delete
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completionHandler) in
        
            let isAdmin = UserDefaults.standard.bool(forKey: "isAdmin")
            print(isAdmin)
            if isAdmin == true {
                
                self.deleteRecipe(recipeId: self.recipes[indexPath.row]._id) { (result) -> () in
                    if(result == true) {
                        self.recipes.remove(at: indexPath.row)
                        
                        RecipeCacheManager.shared.saveRecipes(self.recipes)
                        
                     
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
        return recipes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath) as! ItemTableViewCell
        let recipe = recipes[indexPath.row]
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
        let recipe = recipes[indexPath.row]
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
        
       
        AF.request("\(apiUrl)/\(recipeId)", method: .delete, headers: headers)
            .responseJSON { response in
                switch response.result {
                case .success(let data):
                
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
