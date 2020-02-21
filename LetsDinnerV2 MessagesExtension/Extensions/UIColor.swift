//
//  UIColor.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 05/11/2019.
//  Copyright © 2019 Eric Ordonneau. All rights reserved.
//

import UIKit

extension UIColor {
    
    // MARK: - Semantic Color with Dark Mode
    static var backgroundColor: UIColor {
        if #available(iOS 13, *) {
            return UIColor { (traitCollection: UITraitCollection) -> UIColor in
                if traitCollection.userInterfaceStyle == .dark {
                    return Colors.soBlack
                } else { return Colors.allWhite }}
        } else { return Colors.allWhite }
    }
    
    static var backgroundMirroredColor: UIColor {
        if #available(iOS 13, *) {
            return UIColor { (traitCollection: UITraitCollection) -> UIColor in
                if traitCollection.userInterfaceStyle == .dark {
                    return Colors.allWhite
                } else { return Colors.soBlack }}
        } else { return Colors.soBlack }
    }
    
    static var textLabel: UIColor {
        if #available(iOS 13, *) {
            return UIColor { (traitCollection: UITraitCollection) -> UIColor in
                if traitCollection.userInterfaceStyle == .dark {
                    return Colors.allWhite
                } else { return Colors.soBlack }}
        } else { return Colors.soBlack }
    }
    
    static var secondaryTextLabel: UIColor {
        if #available(iOS 13, *) {
            return UIColor { (traitCollection: UITraitCollection) -> UIColor in
                if traitCollection.userInterfaceStyle == .dark {
                    return Colors.darkStoneGrey
                } else { return Colors.stoneGrey }}
        } else { return Colors.stoneGrey }
    }
    
    static var navigationTitle: UIColor {
        if #available(iOS 13, *) {
            return UIColor { (traitCollection: UITraitCollection) -> UIColor in
                if traitCollection.userInterfaceStyle == .dark {
                    return Colors.allWhite
                } else { return Colors.soBlack }}
        } else { return Colors.soBlack }
    }
    
    static var sectionTitle: UIColor {
        if #available(iOS 13, *) {
            return UIColor { (traitCollection: UITraitCollection) -> UIColor in
                if traitCollection.userInterfaceStyle == .dark {
                    return Colors.allWhite
                } else { return Colors.soBlack }}
        } else { return Colors.soBlack }
    }
    
    static var placeholderText: UIColor {
        if #available(iOS 13, *) {
            return UIColor { (traitCollection: UITraitCollection) -> UIColor in
                if traitCollection.userInterfaceStyle == .dark {
                    return Colors.darkDefaultGrey
                } else { return Colors.defaultGrey }}
        } else { return Colors.defaultGrey }
    }
    
    static var activeButton: UIColor {
        if #available(iOS 13, *) {
            return UIColor { (traitCollection: UITraitCollection) -> UIColor in
                if traitCollection.userInterfaceStyle == .dark {
                    return Colors.darkHighlightRed
                } else { return Colors.highlightRed }}
        } else { return Colors.highlightRed }
    }
    
    static var inactiveButton: UIColor {
        if #available(iOS 13, *) {
            return UIColor { (traitCollection: UITraitCollection) -> UIColor in
                if traitCollection.userInterfaceStyle == .dark {
                    return Colors.darkDefaultGrey
                } else { return Colors.defaultGrey }}
        } else { return Colors.defaultGrey }
    }
    
    static var link: UIColor {
        if #available(iOS 13, *) {
            return UIColor { (traitCollection: UITraitCollection) -> UIColor in
                if traitCollection.userInterfaceStyle == .dark {
                    return Colors.allWhite
                } else { return Colors.soBlack }}
        } else { return Colors.soBlack }
    }
    
    static var viewSeparatorLine: UIColor {
        if #available(iOS 13, *) {
            return UIColor { (traitCollection: UITraitCollection) -> UIColor in
                if traitCollection.userInterfaceStyle == .dark {
                    return Colors.darkDullGrey
                } else { return Colors.dullGrey }}
        } else { return Colors.dullGrey }
    }
    
    static var cellSeparatorLine: UIColor {
        if #available(iOS 13, *) {
            return UIColor { (traitCollection: UITraitCollection) -> UIColor in
                if traitCollection.userInterfaceStyle == .dark {
                    return Colors.darkDefaultGrey
                } else { return Colors.defaultGrey }}
        } else { return Colors.defaultGrey }
    }
    
    static var keyboardBackground: UIColor {
           if #available(iOS 13, *) {
               return UIColor { (traitCollection: UITraitCollection) -> UIColor in
                   if traitCollection.userInterfaceStyle == .dark {
                       return UIColor(red: 27/255, green: 27/255, blue: 27/255, alpha: 1)
                   } else { return UIColor(red: 210/255, green: 211/255, blue: 217/255, alpha: 1) }}
           } else { return UIColor(red: 210/255, green: 211/255, blue: 217/255, alpha: 1) }
       }
    
    static var keyboardSeparator: UIColor {
        if #available(iOS 13, *) {
            return UIColor { (traitCollection: UITraitCollection) -> UIColor in
                if traitCollection.userInterfaceStyle == .dark {
                    return UIColor(red: 47/255, green: 47/255, blue: 47/255, alpha: 1)
                } else { return UIColor(red: 190/255, green: 192/255, blue: 196/255, alpha: 1) }}
        } else { return UIColor(red: 190/255, green: 192/255, blue: 196/255, alpha: 1) }
    }
    
    // MARK: - Functions
    
    func image(_ size: CGSize = CGSize(width: 1, height: 1)) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { rendererContext in
            self.setFill()
            rendererContext.fill(CGRect(origin: .zero, size: size))
        }
    }
}
