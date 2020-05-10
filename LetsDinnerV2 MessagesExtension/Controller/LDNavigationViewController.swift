//
//  LDNavigationViewController.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 03/05/2020.
//  Copyright © 2020 Eric Ordonneau. All rights reserved.
//

import UIKit
import SnapKit

class LDNavigationViewController: UIViewController {
    
    let navigationBar = LDNavBar()
    
    let progressViewContainer = UIView()
    
    let progressVC = ProgressViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
    }

    private func setupUI() {
        view.backgroundColor = .backgroundColor
        view.addSubview(navigationBar)
        view.addSubview(progressViewContainer)
        addChild(progressVC)
        progressViewContainer.addSubview(progressVC.view)
        progressVC.view.frame = progressViewContainer.bounds
        progressVC.didMove(toParent: self)
        addConstraints()
        
    }
    
    
    private func addConstraints() {
        navigationBar.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.height.equalTo(43)
        }
        
        progressViewContainer.snp.makeConstraints { make in
            make.top.equalTo(navigationBar.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(2)
        }
        
        
//
//        progressView.snp.makeConstraints { make in
//            make.top.equalTo(navigationBar.snp.bottom)
//            make.leading.trailing.equalToSuperview()
//            make.height.equalTo(2)
//        }
    }
}
