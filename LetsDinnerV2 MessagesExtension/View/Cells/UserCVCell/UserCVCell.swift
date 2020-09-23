//
//  UserCVCell.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 08/11/2019.
//  Copyright © 2019 Eric Ordonneau. All rights reserved.
//

import UIKit

class UserCVCell: UICollectionViewCell {
    
    static let reuseID = "UserCVCell"
    
    private let userPicture : UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    private let nameLabel : UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 12)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureCell(user: User) {
        var strokeColor = UIColor()
        if user.hasAccepted == .accepted {
            strokeColor = Colors.hasAccepted
        } else if user.hasAccepted == .declined {
            strokeColor = Colors.hasDeclined
        } else if user.hasAccepted == .pending {
            // For Internal Testing
            strokeColor = .darkGray
        }
        if let profilePicUrl = user.profilePicUrl, let imageURL = URL(string: profilePicUrl) {
            userPicture.layer.cornerRadius = userPicture.frame.height/2
            userPicture.clipsToBounds = true
            userPicture.layer.borderWidth = 2.0
            userPicture.layer.borderColor = strokeColor.cgColor
            userPicture.kf.setImage(with: imageURL)
            userPicture.kf.setImage(with: imageURL, placeholder: Images.profilePlaceholder) { result in
                switch result {
                case .success:
                    break
                case .failure:
                    self.setUserPicWithInitials(initials: user.fullName.initials, strokeColor: strokeColor)
                }
            }
        } else {
            setUserPicWithInitials(initials: user.fullName.initials, strokeColor: strokeColor)
        }
        nameLabel.text = user.fullName
    }
    
    private func setUserPicWithInitials(initials: String, strokeColor: UIColor) {
        userPicture.setImage(string: initials, color: .lightGray, circular: true, stroke: true, strokeColor: strokeColor, textAttributes: [NSAttributedString.Key(rawValue: NSAttributedString.Key.font.rawValue): UIFont.systemFont(ofSize: 20, weight: .light), NSAttributedString.Key.foregroundColor: UIColor.white])
    }
    
    private func setupUI() {
        self.backgroundColor = .backgroundColor
        userPicture.frame = CGRect(x: 0, y: 0, width: 55, height: 55)
        self.contentView.addSubview(userPicture)
        self.contentView.addSubview(nameLabel)
        addConstraints()
    }
    
    private func addConstraints() {
        userPicture.snp.makeConstraints { make in
            make.height.width.equalTo(55)
            make.top.centerX.equalToSuperview()
        }
        
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(userPicture.snp.bottom).offset(6)
            make.leading.equalToSuperview().offset(2)
            make.trailing.equalToSuperview().offset(-2)
        }
    }
}
