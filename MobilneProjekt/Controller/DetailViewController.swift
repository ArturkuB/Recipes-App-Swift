import Foundation
import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var instructionsLabel: UILabel!
    @IBOutlet weak var ingredientsLabel: UILabel!
    var recipe: Recipe?
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        if let recipe = recipe {
            titleLabel.text = recipe.name
            let text = NSMutableAttributedString()
            text.append(NSAttributedString(string: "Author: ", attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray]));
            text.append(NSAttributedString(string: recipe.author.uppercased(), attributes: [NSAttributedString.Key.foregroundColor: UIColor.red]))
            authorLabel.attributedText = text
            descriptionLabel.text = recipe.description
                ingredientsLabel.text = "Składniki: " + (recipe.ingredients.first?.replacingOccurrences(of: "\"", with: "") ?? "").replacingOccurrences(of: "[", with: "").replacingOccurrences(of: "]", with: "")
            
            instructionsLabel.text = "Instructions: " + recipe.instructions
            if let url = URL(string: recipe.imageUrl ?? "") {
                    mainImageView.sd_setImage(with: url, completed: nil)
               }
        }
    }
    
    
}
