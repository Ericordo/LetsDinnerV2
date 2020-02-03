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
        self.view.backgroundColor = Colors.allWhite
        progressView.progressTintColor = Colors.highlightRed
        progressView.trackTintColor = Colors.paleGray
    }
    
    @objc func stepProgressing(_ notification: Notification) {
        // Run twice sometimes (example: when it goes back from 5 to 4)
        if let data = notification.userInfo as? [String: Int] {
            let step = data["step"]
            progress.completedUnitCount = Int64(step!)
            progressView.progress = Float(step!)
            let progressFloat = Float(self.progress.fractionCompleted)
            progressView.setProgress(progressFloat, animated: true)
        }
    }
    
}
