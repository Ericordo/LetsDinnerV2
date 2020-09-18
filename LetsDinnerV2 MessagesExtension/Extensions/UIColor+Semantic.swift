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
                    return Colors.darkBlackground
                } else { return Colors.allWhite }}
        } else { return Colors.allWhite }
    }
    
    static var backgroundMirroredColor: UIColor {
        if #available(iOS 13, *) {
            return UIColor { (traitCollection: UITraitCollection) -> UIColor in
                if traitCollection.userInterfaceStyle == .dark {
                    return Colors.allWhite
                } else { return Colors.darkBlackground }}
        } else { return Colors.darkBlackground }
    }
    
    static var backgroundSystemColor: UIColor {
        if #available(iOS 13, *) {
            return UIColor { (traitCollection: UITraitCollection) -> UIColor in
                if traitCollection.userInterfaceStyle == .dark {
                    return Colors.soBlack
                } else { return Colors.allWhite }}
        } else { return Colors.allWhite }
    }
    
    static var bottomViewColor: UIColor {
        return UIColor(named: "bottomViewColor") ?? self.backgroundColor
    }
    
    
    // MARK: Text Label Color
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
                    return Colors.darkDullGrey
                } else { return Colors.dullGrey }}
        } else { return Colors.dullGrey }
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
    
    static var secondaryButtonBackground: UIColor {
        if #available(iOS 13, *) {
            return UIColor { (traitCollection: UITraitCollection) -> UIColor in
                if traitCollection.userInterfaceStyle == .dark {
                    return Colors.darkButtonGrey
                } else { return Colors.paleGray }}
        } else { return Colors.paleGray }
    }
    
    static var tertiaryButtonBackground: UIColor {
        if #available(iOS 13, *) {
            return UIColor { (traitCollection: UITraitCollection) -> UIColor in
                if traitCollection.userInterfaceStyle == .dark {
                    return Colors.darkStoneGrey
                } else { return Colors.allWhite }}
        } else { return Colors.allWhite }
    }
    
    static var buttonTextBlue: UIColor {
        if #available(iOS 13, *) {
            return UIColor { (traitCollection: UITraitCollection) -> UIColor in
                if traitCollection.userInterfaceStyle == .dark {
                    return Colors.darkOkayBlue
                } else { return Colors.okayBlue }}
            } else { return Colors.okayBlue }
    }
    
    static var buttonTextRed: UIColor {
        if #available(iOS 13, *) {
            return UIColor { (traitCollection: UITraitCollection) -> UIColor in
                if traitCollection.userInterfaceStyle == .dark {
                    return Colors.darkJustNoRed
                } else { return Colors.justNoRed }}
            } else { return Colors.justNoRed }
    }
    
    static var swipeRightButton: UIColor {
        if #available(iOS 13, *) {
            return UIColor { (traitCollection: UITraitCollection) -> UIColor in
                if traitCollection.userInterfaceStyle == .dark {
                    return Colors.darkDullGrey
                } else { return Colors.dullGrey }}
            } else { return Colors.dullGrey }
    }

    static var link: UIColor {
        if #available(iOS 13, *) {
            return UIColor { (traitCollection: UITraitCollection) -> UIColor in
                if traitCollection.userInterfaceStyle == .dark {
                    return Colors.allWhite
                } else { return Colors.soBlack }}
        } else { return Colors.soBlack }
    }
    
    static var sectionSeparatorLine: UIColor {
        if #available(iOS 13, *) {
            return UIColor { (traitCollection: UITraitCollection) -> UIColor in
                if traitCollection.userInterfaceStyle == .dark {
                    return Colors.darkDefaultGrey
                } else { return Colors.defaultGrey }}
        } else { return Colors.defaultGrey }
    }
    
    static var cellSeparatorLine: UIColor {
        if #available(iOS 13, *) {
            return UIColor { (traitCollection: UITraitCollection) -> UIColor in
                if traitCollection.userInterfaceStyle == .dark {
                    return Colors.darkDefaultGrey
                } else { return Colors.defaultGrey }}
        } else { return Colors.defaultGrey }
    }
    
    static var bubbleBottom: UIColor {
        if #available(iOS 13, *) {
            return UIColor { (traitCollection: UITraitCollection) -> UIColor in
                if traitCollection.userInterfaceStyle == .dark {
                    return Colors.bubbleBlack
                } else { return Colors.bubbleGrey }}
        } else { return Colors.bubbleGrey }
    }

    // MARK: Keyboard
    static var keyboardBackground: UIColor {
           if #available(iOS 13, *) {
               return UIColor { (traitCollection: UITraitCollection) -> UIColor in
                   if traitCollection.userInterfaceStyle == .dark {
                       return UIColor(red: 31/255, green: 31/255, blue: 31/255, alpha: 1)
                   } else { return UIColor(red: 214/255, green: 216/255, blue: 221/255, alpha: 1) }}
           } else { return UIColor(red: 214/255, green: 216/255, blue: 221/255, alpha: 1) }
       }
    
    static var keyboardSeparator: UIColor {
        if #available(iOS 13, *) {
            return UIColor { (traitCollection: UITraitCollection) -> UIColor in
                if traitCollection.userInterfaceStyle == .dark {
                    return UIColor(red: 80/255, green: 80/255, blue: 80/255, alpha: 1)
                } else { return UIColor(red: 190/255, green: 192/255, blue: 196/255, alpha: 1) }}
        } else { return UIColor(red: 190/255, green: 192/255, blue: 196/255, alpha: 1) }
    }
    
    static var customRecipeBackground: UIColor {
        if #available(iOS 13, *) {
            return UIColor { (traitCollection: UITraitCollection) -> UIColor in
                if traitCollection.userInterfaceStyle == .dark {
                    return UIColor(red: 28/255, green: 28/255, blue: 30/255, alpha: 1)
                } else { return Colors.paleGray }}
        } else { return Colors.paleGray }
    }

    // MARK: - Functions
    
    func image(_ size: CGSize = CGSize(width: 1, height: 1)) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { rendererContext in
            self.setFill()
            rendererContext.fill(CGRect(origin: .zero, size: size))
        }
    }
}
