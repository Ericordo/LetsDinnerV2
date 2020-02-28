//
//  ProgressViewController.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Alex Cheung on 1/2/2020.
//  Copyright © 2020 Eric Ordonneau. All rights reserved.
//

import UIKit

class ProgressViewController: UIViewController {

    @IBOutlet weak var progressView: UIProgressView!
    
    let progress = Progress(totalUnitCount: 5)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        self.progressView.progress = 0
        
//        NotificationCenter.default.addObserver(self, selector: #selector(stepProgressing), name: Notification.Name("didGoToNextStep"), object: nil)
        
        NotificationCenter.default.addObserver(forName: Notification.Name("didGoToNextStep"),
                                                object: nil,
                                                queue: nil,
                                                using: stepProgressing(_:))

    }
        
    private func configureUI() {
        self.view.backgroundColor = .clear
        progressView.progressTintColor = UIColor.activeButton
        progressView.trackTintColor = UIColor.inactiveButton
    }
    
    @objc func stepProgressing(_ notification: Notification) {
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
    
    func removeViewController() {
        print("RemoveViewController")
//        self.removeFromParent()
//        self.view.removeFromSuperview()
    }
    
}
