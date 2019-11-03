//
//  InitialViewController.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 02/11/2019.
//  Copyright © 2019 Eric Ordonneau. All rights reserved.
//

import UIKit

protocol InitialViewControllerDelegate: class {
    func initialVCDidTapStartButton(controller: InitialViewController)
    func initialVCDidTapInfoButton(controller: InitialViewController)
}

class InitialViewController: UIViewController {

    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var newDinnerButton: UIButton!
    
    weak var delegate: InitialViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()

        
        
        
    }
    
    func setupUI() {
        backgroundView.setGradient(colorOne: Colors.gradientRed, colorTwo: Colors.gradientPink)
        newDinnerButton.layer.cornerRadius = 8.0
     
        
    }
    
    
    @IBAction func didTapInfo(_ sender: UIButton) {
        delegate?.initialVCDidTapInfoButton(controller: self)
    }
    

    @IBAction func didTapNewDinner(_ sender: Any) {
        delegate?.initialVCDidTapStartButton(controller: self)
    }
    



}


