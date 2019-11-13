//
//  IdleViewController.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 12/11/2019.
//  Copyright © 2019 Eric Ordonneau. All rights reserved.
//

import UIKit

protocol IdleViewControllerDelegate: class {
    func idleVCDidTapContinue(controller: IdleViewController)
    func idleVCDidTapNewDinner(controller: IdleViewController)
}

class IdleViewController: UIViewController {

    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var newDinnerButton: UIButton!
    
     weak var delegate: IdleViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()

        // Do any additional setup after loading the view.
    }

    
    func setupUI() {
        view.setGradientToValue(colorOne: Colors.newGradientPink, colorTwo: Colors.newGradientRed, value: 0.4)
        continueButton.layer.cornerRadius = 8.0
        newDinnerButton.layer.cornerRadius = 8.0
    }
    
    @IBAction func didTapContinue(_ sender: UIButton) {
        delegate?.idleVCDidTapContinue(controller: self)
    }
    
    @IBAction func didTapNewDinner(_ sender: Any) {
        delegate?.idleVCDidTapNewDinner(controller: self)
    }
    
    
    

}
