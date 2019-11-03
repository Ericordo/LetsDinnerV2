//
//  NewEventViewController.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 03/11/2019.
//  Copyright © 2019 Eric Ordonneau. All rights reserved.
//

import UIKit

protocol NewEventViewControllerDelegate: class {
    
}

class NewEventViewController: UIViewController {
    
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dinnerNameTextField: UITextField!
    @IBOutlet weak var hostNameTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    weak var delegate: NewEventViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        

        // Do any additional setup after loading the view.
    }

    func setupUI() {
        errorLabel.isHidden = true
    }

   
}
