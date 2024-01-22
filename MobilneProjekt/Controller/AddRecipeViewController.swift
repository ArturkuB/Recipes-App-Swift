import UIKit
import Alamofire
import AlamofireImage

class AddRecipeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var authorField: UITextField!
    @IBOutlet weak var cookingTimeField: UITextField!
    @IBOutlet weak var servingsField: UITextField!
    @IBOutlet weak var ingredientsField: UITextField!
    @IBOutlet weak var descriptionField: UITextField!
    @IBOutlet weak var instructionsField: UITextField!
    @IBOutlet weak var filenameLabel: UILabel!

    @IBOutlet weak var urlField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    
    let url = "https://eprzepisy-rest-f12cad5c96bf.herokuapp.com"
    var selectedImage: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
        titleField.text = "Polski bigos"
        authorField.text = "Andrzej"
        cookingTimeField.text = "230"
        servingsField.text = "6"
        ingredientsField.text = "Kapusta, kiełbasa, talerz"
        descriptionField.text = "Polski bigos"
        instructionsField.text = "Zamówić przez uber eats"
        urlField.text = "https://s3.przepisy.pl/przepisy3ii/img/variants/800x0/bigos-video.jpg"
        sendButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapOutsideTextField))
        view.addGestureRecognizer(tapGesture)
    }

    @objc func fileButtonTapped() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true, completion: nil)
    }

    @objc func sendButtonTapped() {
        createRecipe { recipeId in
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @objc func handleTapOutsideTextField() {
        view.endEditing(true)
    }

    // MARK: - UIImagePickerControllerDelegate

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage,
           let imageUrl = info[UIImagePickerController.InfoKey.imageURL] as? URL {
            
            selectedImage = pickedImage
            filenameLabel.text = "\(imageUrl.lastPathComponent)"
        }

        dismiss(animated: true, completion: nil)
    }

    // MARK: - Zapytanie POST

    func createRecipe(completion: @escaping (String?) -> Void) {
        let ingredientsString = ingredientsField.text ?? ""
        let ingredientsArray = ingredientsString.components(separatedBy: ", ")

        guard let userId = UserDefaults.standard.string(forKey: "userId") else {
            print("Użytkownik nie został znaleziony.")
            completion(nil)
            return
        }
        
        let parameters: [String: Any] = [
            "author": authorField.text ?? "",
            "name": titleField.text ?? "",
            "userId": userId,
            "cookingTime": cookingTimeField.text ?? "",
            "servings": servingsField.text ?? "",
            "description": descriptionField.text ?? "",
            "instructions": instructionsField.text ?? "",
            "ingredients": ingredientsArray,
            "imageUrl": urlField.text ?? ""
        ]

        guard let token = UserDefaults.standard.string(forKey: "AuthToken") else {
            print("Token JWT nie został znaleziony.")
            completion(nil)
            return
        }

        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)"
        ]

        AF.request("\(url)/recipes/", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .responseJSON { response in
                switch response.result {
                case .success(let data):
                    if let jsonData = data as? [String: Any],
                       let createdRecipe = jsonData["createdRecipe"] as? [String: Any],
                       let recipeId = createdRecipe["_id"] as? String {
                        print("Recipe created successfully: \(createdRecipe)")
                        completion(recipeId)
                    } else {
                        print("Invalid JSON response")
                        completion(nil)
                    }

                case .failure(let error):
                    print("Error creating recipe: \(error)")
                    completion(nil)
                }
            }

    }
}
