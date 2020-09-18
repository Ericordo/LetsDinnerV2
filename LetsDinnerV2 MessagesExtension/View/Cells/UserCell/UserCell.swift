//
//  UserCell.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 06/11/2019.
//  Copyright © 2019 Eric Ordonneau. All rights reserved.
//

import UIKit

class UserCell: UITableViewCell {
    
    static let reuseID = "UserCell"
    
    private let titleLabel : UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.text = LabelStrings.whocoming
        return label
    }()
    
    private let peopleCollectionView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 60, height: 100)
        layout.minimumInteritemSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 0, left: 28, bottom: 0, right: 0)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .backgroundColor
        cv.showsHorizontalScrollIndicator = false
        return cv
    }()
    
    private let sortedParticipants = Event.shared.participants.sorted { $0.fullName < $1.fullName}

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCell() {
        self.backgroundColor = .backgroundColor
        self.selectionStyle = .none
        peopleCollectionView.backgroundColor = .backgroundColor
        peopleCollectionView.delegate = self
        peopleCollectionView.dataSource = self
        peopleCollectionView.register(UserCVCell.self,
                                      forCellWithReuseIdentifier: UserCVCell.reuseID)
        contentView.addSubview(titleLabel)
        contentView.addSubview(peopleCollectionView)
        addConstraints()
    }
    
    private func addConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(32)
            make.top.equalToSuperview().offset(14)
            
        }
        
        peopleCollectionView.snp.makeConstraints { make in
            make.bottom.leading.trailing.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(15)
        }
    }
}

extension UserCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Event.shared.participants.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let userCVCell = collectionView.dequeueReusableCell(withReuseIdentifier: UserCVCell.reuseID,
                                                            for: indexPath) as! UserCVCell
        let user = sortedParticipants[indexPath.row]
        userCVCell.configureCell(user: user)
        return userCVCell
    }
}
