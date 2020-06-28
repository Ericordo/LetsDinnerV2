//
//  RecipeBookViewController.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 24/06/2020.
//  Copyright © 2020 Eric Ordonneau. All rights reserved.
//

import UIKit
import PDFKit

class RecipeBookViewController: LDNavigationViewController {
    
    private var documentData : Data
    private var pdfView = PDFView()
    
    init(documentData: Data) {
        self.documentData = documentData
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    @objc private func didTapShare() {
        let vc = UIActivityViewController(activityItems: [documentData], applicationActivities: [])
        present(vc, animated: true, completion: nil)
    }
    
    private func setupUI() {
        view.backgroundColor = .backgroundColor
        navigationBar.nextButton.setImage(Images.addButtonOutlined, for: .normal)
        navigationBar.nextButton.setTitle("", for: .normal)
        navigationBar.nextButton.addTarget(self, action: #selector(didTapShare), for: .touchUpInside)
        navigationBar.previousButton.isHidden = true
        navigationBar.titleLabel.text = LabelStrings.recipeBook
        NotificationCenter.default.addObserver(self,
        selector: #selector(closeVC),
        name: Notification.Name(rawValue: "WillTransition"),
        object: nil)
        pdfView.document = PDFDocument(data: documentData)
        pdfView.autoScales = true
        pdfView.enableDataDetectors = true
        view.addSubview(pdfView)
        addConstraints()
    }
    
    private func addConstraints() {
        pdfView.snp.makeConstraints { make in
            make.top.equalTo(navigationBar.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
}

