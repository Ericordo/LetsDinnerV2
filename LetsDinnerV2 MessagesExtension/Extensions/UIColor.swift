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
    
    static var textLabel: UIColor {
        if #available(iOS 13, *) {
            return UIColor { (traitCollection: UITraitCollection) -> UIColor in
                if traitCollection.userInterfaceStyle == .dark {
                    return Colors.allWhite
                } else { return Colors.soBlack }}
        } else { return Colors.soBlack }
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
                    return Colors.allWhite
                } else { return Colors.soBlack }}
        } else { return Colors.soBlack }
    }
    
    static var activeButton: UIColor {
        if #available(iOS 13, *) {
            return UIColor { (traitCollection: UITraitCollection) -> UIColor in
                if traitCollection.userInterfaceStyle == .dark {
                    return Colors.darkHighlightRed
                } else { return Colors.highlightRed }}
        } else { return Colors.highlightRed }
    }
    
    static var link: UIColor {
        if #available(iOS 13, *) {
            return UIColor { (traitCollection: UITraitCollection) -> UIColor in
                if traitCollection.userInterfaceStyle == .dark {
                    return Colors.allWhite
                } else { return Colors.soBlack }}
        } else { return Colors.soBlack }
    }
    
    static var cellSeperatorLine: UIColor {
        if #available(iOS 13, *) {
            return UIColor { (traitCollection: UITraitCollection) -> UIColor in
                if traitCollection.userInterfaceStyle == .dark {
                    return Colors.allWhite
                } else { return Colors.soBlack }}
        } else { return Colors.soBlack }
    }
    
    static var viewSeperatorLine: UIColor {
        if #available(iOS 13, *) {
            return UIColor { (traitCollection: UITraitCollection) -> UIColor in
                if traitCollection.userInterfaceStyle == .dark {
                    return Colors.allWhite
                } else { return Colors.soBlack }}
        } else { return Colors.soBlack }
    }
    
    // MARK: - Functions
    
    func image(_ size: CGSize = CGSize(width: 1, height: 1)) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { rendererContext in
            self.setFill()
            rendererContext.fill(CGRect(origin: .zero, size: size))
        }
    }
}
