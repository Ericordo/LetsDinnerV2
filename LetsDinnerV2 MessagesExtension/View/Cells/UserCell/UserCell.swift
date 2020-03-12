//
//  UserCell.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 06/11/2019.
//  Copyright © 2019 Eric Ordonneau. All rights reserved.
//

import UIKit

class UserCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var peopleCollectionView: UICollectionView!
    
    let sortedParticipants = Event.shared.participants.sorted { $0.fullName < $1.fullName}

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = .backgroundColor
        peopleCollectionView.backgroundColor = .backgroundColor

        peopleCollectionView.delegate = self
        peopleCollectionView.dataSource = self
        peopleCollectionView.register(UINib(nibName: CellNibs.userCVCell, bundle: nil), forCellWithReuseIdentifier: CellNibs.userCVCell)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

extension UserCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Event.shared.participants.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let userCVCell = collectionView.dequeueReusableCell(withReuseIdentifier: CellNibs.userCVCell, for: indexPath) as! UserCVCell
        let user = sortedParticipants[indexPath.row]
        userCVCell.configureCell(user: user)
        return userCVCell
    }
}
