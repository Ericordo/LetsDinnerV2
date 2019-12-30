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
    func idleVCDidTapProfileButton(controller: IdleViewController)
}

class IdleViewController: UIViewController {

    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var newDinnerButton: UIButton!
    @IBOutlet weak var profileButton: UIButton!
    
     weak var delegate: IdleViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidLayoutSubviews() {
        let gradientLayers = view.layer.sublayers?.compactMap { $0 as? CAGradientLayer }
        gradientLayers?.first?.frame = view.bounds
    }

    func setupUI() {
        continueButton.layer.cornerRadius = 8.0
        newDinnerButton.layer.cornerRadius = 8.0
        view.setGradient(colorOne: Colors.newGradientPink, colorTwo: Colors.newGradientRed)
    }
    
    @IBAction func didTapContinue(_ sender: UIButton) {
        delegate?.idleVCDidTapContinue(controller: self)
    }
    
    @IBAction func didTapNewDinner(_ sender: Any) {
        delegate?.idleVCDidTapNewDinner(controller: self)
    }
    
    
    @IBAction func didTapProfileButton(_ sender: UIButton) {
        delegate?.idleVCDidTapProfileButton(controller: self)
    }
    
    

}
