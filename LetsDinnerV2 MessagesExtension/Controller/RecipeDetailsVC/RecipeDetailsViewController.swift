//
//  RecipeDetailsViewController.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 05/11/2019.
//  Copyright © 2019 Eric Ordonneau. All rights reserved.
//

import UIKit
import WebKit
import SafariServices

protocol RecipeDetailsViewControllerDelegate: class {
    func recipeDetailsVCShouldDismiss(_ controller: RecipeDetailsViewController)
}

class RecipeDetailsViewController: UIViewController {

    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var chooseButton: UIButton!
    @IBOutlet weak var chosenButton: UIButton!
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var recipeName: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    
    var selectedRecipe: Recipe?
    weak var delegate: RecipeDetailsViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.navigationDelegate = self
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        setupUI()
        
    }
    
    func setupUI() {
        progressView.tintColor = Colors.customPink
        chooseButton.layer.cornerRadius = 10
        
        guard let recipe = selectedRecipe else { return }
        recipeName.text = recipe.title
        webView.load(URLRequest(url: URL(string: recipe.sourceUrl!)!))
        let isSelected = Event.shared.selectedRecipes.contains(where: { $0.title == recipe.title! })
        chooseButton.isHidden = isSelected
        chosenButton.isHidden = !isSelected
    }

    @IBAction func didTapDone(_ sender: UIButton) {
        delegate?.recipeDetailsVCShouldDismiss(self)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapChoose(_ sender: UIButton) {
        chooseButton.isHidden = chosenButton.isHidden
        chosenButton.isHidden = !chooseButton.isHidden
        guard let recipe = selectedRecipe else { return }
        if let index = Event.shared.selectedRecipes.firstIndex(where: { $0.title == recipe.title! }) {
                  Event.shared.selectedRecipes.remove(at: index)
              } else {
                  Event.shared.selectedRecipes.append(recipe)
              }
    }
    
    @IBAction func didTapChosen(_ sender: Any) {
        chooseButton.isHidden = chosenButton.isHidden
        chosenButton.isHidden = !chooseButton.isHidden
        guard let recipe = selectedRecipe else { return }
        if let index = Event.shared.selectedRecipes.firstIndex(where: { $0.title == recipe.title! }) {
                  Event.shared.selectedRecipes.remove(at: index)
              } else {
                  Event.shared.selectedRecipes.append(recipe)
              }
    }
    

}

extension RecipeDetailsViewController: WKNavigationDelegate {
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            progressView.isHidden = webView.estimatedProgress == 1
            progressView.progress = Float(webView.estimatedProgress)
        }
    }
}
