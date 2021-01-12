//
//  LeftAlignedFlowLayout.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 10/01/2021.
//  Copyright © 2021 Eric Ordonneau. All rights reserved.
//

import UIKit

class LeftAlignedFlowLayout: UICollectionViewFlowLayout {

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let attributes = super.layoutAttributesForElements(in: rect)

        var leftMargin = sectionInset.left
        var maxY: CGFloat = -1.0
        attributes?.forEach { layoutAttribute in
            if layoutAttribute.frame.origin.y >= maxY {
                leftMargin = sectionInset.left
            }

            layoutAttribute.frame.origin.x = leftMargin

            leftMargin += layoutAttribute.frame.width + minimumInteritemSpacing
            maxY = max(layoutAttribute.frame.maxY , maxY)
        }

        return attributes
    }
}
