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

enum DefaultSectionName {
    case miscellaneous
    case name
    
    var labelString: String {
        switch self {
        case .miscellaneous:
            return LabelStrings.misc
        default:
            #warning("Necessary? If yes localize")
            return "Name"
        }
    }
}

class SectionSelectionInput : UIView {
    
    private var viewFirstInit = true
    var type: AddNewThingViewType!
        
    init(type: AddNewThingViewType) {
        self.type = type
        super.init(frame: CGRect.zero)
        configureView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    weak var sectionSelectionInputDelegate : SectionSelectionInputDelegate?
    
    let sectionsCollectionView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .backgroundSystemColor
        cv.showsHorizontalScrollIndicator = false
        return cv
    }()
    
    var sections = [String]() {
        didSet {
            sectionsCollectionView.reloadData()
        }
    }
    
    private func configureView() {
        if type == .manageTask {
            sections.insert(DefaultSectionName.miscellaneous.labelString, at: 0)
        }
        
        self.backgroundColor = .backgroundSystemColor
        sectionsCollectionView.dataSource = self
        sectionsCollectionView.delegate = self
        sectionsCollectionView.register(SectionInputCell.self,
                                        forCellWithReuseIdentifier: SectionInputCell.reuseID)
        
        // These 2 lines did not fix the bug of the toolbar not always appearing
        self.sizeToFit()
        self.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        addSubview(sectionsCollectionView)
    }
    
    override func layoutSubviews() {
        // Maybe adding constraints in layoutSubviews fix the bug of the toolnar not always appearing
        addConstraints()
        
        if viewFirstInit {
            // Show the selected bubble (First time)
            sectionsCollectionView.selectItem(at: [0,0], animated: true, scrollPosition: .top)
            viewFirstInit = false
        }
        
    }
    
    func configureInput(sections: [String]) {
        sections.forEach { section in
            if !self.sections.contains(section) {
                self.sections.append(section)
            }
        }
    }
    
    private func addConstraints() {
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SectionInputCell.reuseID, for: indexPath) as! SectionInputCell
        let section = sections[indexPath.row]
        cell.configure(sectionName: section)
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
