//
//  SectionSelectionInput.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 06/12/2019.
//  Copyright © 2019 Eric Ordonneau. All rights reserved.
//

import UIKit

protocol SectionSelectionInputDelegate : class {
    func updateSelectedSection(sectionName: String)
}

class SectionSelectionInput : UIView {
    
    var type: AddNewThingViewType!
        
    init(type: AddNewThingViewType) {
        self.type = type
        super.init(frame: CGRect.zero)
        configureView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    var sections = [String]()
    
    weak var sectionSelectionInputDelegate : SectionSelectionInputDelegate?
    
    private let arrowImage : UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "arrowIcon")
        return imageView
    }()
    
    let sectionsCollectionView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .backgroundSystemColor
        cv.showsHorizontalScrollIndicator = false
        return cv
    }()
    
    private func configureView() {
        if type == .manageTask {
            sections.append("Miscellaneous")
        }
        
        self.backgroundColor = .backgroundSystemColor
        sectionsCollectionView.dataSource = self
        sectionsCollectionView.delegate = self
        sectionsCollectionView.register(UINib(nibName: CellNibs.sectionInputCell, bundle: nil), forCellWithReuseIdentifier: CellNibs.sectionInputCell)
        
// These 2 lines did not fix the bug of the toolbar not always appearing
      self.sizeToFit()
      self.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    
    }
    
    override func layoutSubviews() {
    // Maybe adding constraints in layoutSubviews fix the bug of the toolnar not always appearing
        addConstraints()
        
        // Control the selected bubble
        sectionsCollectionView.selectItem(at: [0,0], animated: true, scrollPosition: .left)
    }
    
    func configureInput(sections: [String]) {
        sections.forEach { section in
            if !self.sections.contains(section) {
                self.sections.append(section)
            }
        }
    }
    
    private func addConstraints() {
//        addSubview(arrowImage)
//
//        arrowImage.translatesAutoresizingMaskIntoConstraints = false
//        arrowImage.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10).isActive = true
//        arrowImage.widthAnchor.constraint(equalToConstant: 24).isActive = true
//        arrowImage.heightAnchor.constraint(equalToConstant: 20).isActive = true
//        arrowImage.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0).isActive = true

        addSubview(sectionsCollectionView)
        
        sectionsCollectionView.translatesAutoresizingMaskIntoConstraints = false
        sectionsCollectionView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        sectionsCollectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
        sectionsCollectionView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10).isActive = true
        sectionsCollectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -15).isActive = true
    }
}

extension SectionSelectionInput: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellNibs.sectionInputCell, for: indexPath) as! SectionInputCell
        let section = sections[indexPath.row]
        cell.configureCell(sectionName: section)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        sectionSelectionInputDelegate?.updateSelectedSection(sectionName: sections[indexPath.row])
    }
    
    
}

extension SectionSelectionInput: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 200, height: 34)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
}
