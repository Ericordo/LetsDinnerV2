//
//  RecipeCreationViewController.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 04/12/2019.
//  Copyright © 2019 Eric Ordonneau. All rights reserved.
//

import UIKit

class RecipeCreationViewController: UIViewController {
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var recipeImageView: UIImageView!
    @IBOutlet weak var addImageButton: UIButton!
    @IBOutlet weak var recipeNameTextField: UITextField!
    @IBOutlet weak var servingsTextField: UITextField!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
    }
    
    private func setupUI() {
        
    }
    
    
    @IBAction func didTapCancel(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    

    @IBAction func didTapDone(_ sender: Any) {
    }
    
    @IBAction func didTapAddImage(_ sender: UIButton) {
    }
    

}
