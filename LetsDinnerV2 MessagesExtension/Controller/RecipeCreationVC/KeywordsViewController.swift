//
//  KeywordsViewController.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 10/01/2021.
//  Copyright © 2021 Eric Ordonneau. All rights reserved.
//

import UIKit
import ReactiveSwift

class KeywordsViewController: UIViewController {
    
    private lazy var titleLabel : UILabel = {
        let label = UILabel()
        label.textColor = .secondaryTextLabel
        label.font = .systemFont(ofSize: 13)
        label.text = LabelStrings.keywords
        return label
    }()
    
    private lazy var titleSeparator = separator()
    
    private let textFieldView = UIView()
    
    let keywordField : UITextField = {
        let tf = UITextField()
        tf.placeholder = LabelStrings.keyword
        tf.borderStyle = .none
        tf.clearButtonMode = .whileEditing
        tf.textColor = .textLabel
        tf.font = .systemFont(ofSize: 17)
        tf.tintColor = .activeButton
        tf.returnKeyType = .done
        return tf
    }()
    
    let addButton : UIButton = {
        let button = UIButton()
        button.setImage(Images.addButton, for: .normal)
        return button
    }()
    
    private let separator : UIView = {
        let view = UIView()
        view.backgroundColor = .sectionSeparatorLine
        return view
    }()
    
    let tagCollectionView : UICollectionView = {
        let layout = LeftAlignedFlowLayout()
        layout.scrollDirection = .vertical
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        layout.minimumInteritemSpacing = 10
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.showsVerticalScrollIndicator = false
        cv.backgroundColor = .backgroundColor
        return cv
    }()

    private let viewModel : RecipeCreationViewModel
    
    init(viewModel: RecipeCreationViewModel)  {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCollectionView()
        bindViewModel()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let keywordFieldHeight : CGFloat = 44
        preferredContentSize.height = tagCollectionView.contentSize.height + 22 + keywordFieldHeight
    }
    
    private func bindViewModel() {
        self.viewModel.keywords.producer
            .observe(on: UIScheduler())
            .take(duringLifetimeOf: self)
            .startWithValues { [unowned self] steps in
                self.updateCollectionViewLayout()
            }
        
        self.addButton.reactive
            .controlEvents(.touchUpInside)
            .take(duringLifetimeOf: self)
            .observeValues { [unowned self] _ in
                self.addKeyword(self.keywordField.text!)
            }
        
        self.viewModel.creationMode.producer
            .observe(on: UIScheduler())
            .take(duringLifetimeOf: self)
            .startWithValues { [unowned self] creationMode in
                self.tagCollectionView.reloadData()
                self.textFieldView.isHidden = !creationMode
            }
    }
    
    private func addKeyword(_ keyword: String) {
        guard !keyword.isEmpty else {
            self.keywordField.shake()
            return
        }
        let tag = keyword.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !tag.isEmpty else {
            self.keywordField.shake()
            return }
        self.viewModel.keywords.value.append(tag)
        self.keywordField.text = ""
        self.keywordField.becomeFirstResponder()
    }

    @objc private func deleteKeyword(sender: UIButton) {
        let index : Int = (sender.layer.value(forKey: "index")) as! Int
        self.viewModel.keywords.value.remove(at: index)
    }

    private func updateCollectionViewLayout() {
        self.tagCollectionView.snp.updateConstraints { make in
            make.height.equalTo(CGFloat.greatestFiniteMagnitude)
            make.top.equalTo(titleSeparator.snp.bottom).offset(viewModel.keywords.value.isEmpty ? 0 : 5)
        }
        self.tagCollectionView.reloadData()
        self.tagCollectionView.layoutIfNeeded()
        self.tagCollectionView.snp.updateConstraints { make in
            make.height.equalTo(self.tagCollectionView.contentSize.height)
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .backgroundColor
        view.addSubview(titleLabel)
        view.addSubview(titleSeparator)
        view.addSubview(tagCollectionView)
        textFieldView.addSubview(separator)
        textFieldView.addSubview(addButton)
        textFieldView.addSubview(keywordField)
        view.addSubview(textFieldView)
        addConstraints()
    }
    
    private func setupCollectionView() {
        self.tagCollectionView.delegate = self
        self.tagCollectionView.dataSource = self
        self.tagCollectionView.register(TagCell.self,
                                        forCellWithReuseIdentifier: TagCell.reuseID)
    }
    
    private func addConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.height.equalTo(16)
        }
        
        titleSeparator.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(5)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(1)
        }
        
        tagCollectionView.snp.makeConstraints { make in
            make.top.equalTo(titleSeparator.snp.bottom).offset(5)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview().offset(-5)
            make.height.equalTo(0)
        }
        
        separator.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        addButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(2)
            make.width.height.equalTo(22)
        }
        
        keywordField.snp.makeConstraints { make in
            make.leading.equalTo(addButton.snp.trailing).offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.top.equalToSuperview()
            make.bottom.equalTo(separator.snp.top)
        }
        
        textFieldView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(44)
            make.top.equalTo(tagCollectionView.snp.bottom)
        }
    }
}

extension KeywordsViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel.keywords.value.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TagCell.reuseID, for: indexPath) as! TagCell
        let tag = self.viewModel.keywords.value[indexPath.row]
//        let deletingAllowed = self.viewModel.creationMode.value || self.viewModel.recipe != nil && 
        cell.configureCell(tag: tag, deletingAllowed: self.viewModel.creationMode.value)
        cell.deleteButton.layer.setValue(indexPath.row, forKey: "index")
        cell.deleteButton.addTarget(self,
                                    action: #selector(deleteKeyword(sender:)),
                                    for: .touchUpInside)
        return cell
    }
}
