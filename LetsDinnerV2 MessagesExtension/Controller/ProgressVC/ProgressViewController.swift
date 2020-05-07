//
//  ProgressViewController.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Alex Cheung on 1/2/2020.
//  Copyright © 2020 Eric Ordonneau. All rights reserved.
//

import UIKit
import SnapKit

class ProgressViewController: UIViewController {

    private let progressView : UIProgressView = {
        let view = UIProgressView()
        view.progressTintColor = UIColor.activeButton
        view.trackTintColor = UIColor.inactiveButton
        return view
    }()
    
    var progress = Progress(totalUnitCount: 5)
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        progress.completedUnitCount = Int64(StepStatus.currentStep!.stepNumber)
        let progressFloat = Float(self.progress.fractionCompleted)
        progressView.progress = progressFloat
                NotificationCenter.default.addObserver(self, selector: #selector(hideProgressBar), name: Notification.Name(rawValue: "WillTransition"), object: nil)
//        setupNotifications()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        progress.completedUnitCount = Int64(StepStatus.currentStep!.stepNumber)
        let progressFloat = Float(self.progress.fractionCompleted)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { // Execute after Page animation
            self.progressView.setProgress(progressFloat, animated: true)
        }
    }
        
    func setupNotifications() {
        NotificationCenter.default.addObserver(forName: Notification.Name("didGoToNextStep"),
                                                object: nil,
                                                queue: nil,
                                                using: animateProgress(_:))
        
        NotificationCenter.default.addObserver(forName: Notification.Name("ProgressBarWillTransition"),
                                                object: nil,
                                                queue: nil,
                                                using: setProgressBarVisibility(_:))
    }
    

    private func setupUI() {
        self.view.addSubview(progressView)
        addConstraints()
    }
    
    private func addConstraints() {
        progressView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    @objc private func hideProgressBar() {
        print("hide progress bar")
        self.progressView.isHidden = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { // Execute after Page animation
            self.progressView.isHidden = false
        }
        
    }
    
    @objc func animateProgress(_ notification: Notification) {
        // Run twice sometimes (example: when it goes back from 5 to 4)
        
        if let data = notification.userInfo as? [String: Int] {
            let step = data["step"]
            progress.completedUnitCount = Int64(step!)

            let progressFloat = Float(self.progress.fractionCompleted)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { // Execute after Page animation
                self.progressView.setProgress(progressFloat, animated: true)
            }

        }
    }
    
    @objc func setProgressBarVisibility(_ notification: Notification) {
        
        if let data = notification.userInfo as? [String: Int] {
            let style = data["style"]
            
            if style == 1 {
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    UIView.transition(with: self.view,
                                      duration: 0.5,
                                      options: .transitionCrossDissolve,
                                      animations: {
                                        self.progressView.isHidden = false
                    })
                }
                
                
                
            } else if style == 0 {
                // to compact mode
                progressView.isHidden = true
            }
        }
        

        
    }
    
}
