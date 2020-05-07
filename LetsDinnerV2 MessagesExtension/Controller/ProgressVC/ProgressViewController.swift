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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        progress.completedUnitCount = Int64(StepStatus.currentStep!.stepNumber)
        let progressFloat = Float(self.progress.fractionCompleted)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { // Execute after Page animation
            self.progressView.setProgress(progressFloat, animated: true)
        }
    }
    
    @objc private func hideProgressBar() {
        self.progressView.isHidden = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { // Execute after Page animation
            self.progressView.isHidden = false
        }
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
}
