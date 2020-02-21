//
//  Colors.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Alex Cheung on 31/1/2020.
//  Copyright © 2020 Eric Ordonneau. All rights reserved.
//

import UIKit

enum Colors {
    // New Color
    static let soBlack = UIColor(red: 0, green: 0, blue: 0, alpha: 1.0)
    static let allWhite = UIColor(red: 1, green: 1, blue: 1, alpha: 1.0)
    
    // Red
    static let highlightRed = UIColor(red: 242/255, green: 89/255, blue: 82/255, alpha: 1.0)
    static let justNoRed = UIColor(red: 255/255, green: 59/255, blue: 48/255, alpha: 1.0)
    static let peachPink = UIColor(red: 242/255, green: 120/255, blue: 135/255, alpha: 1.0)
    
    static let darkHighlightRed = UIColor(red: 242/255, green: 99/255, blue: 92/255, alpha: 1.0)
    static let darkJustNoRed = UIColor(red: 255/255, green: 69/255, blue: 58/255, alpha: 1.0)
    static let darkPeachPink = UIColor(red: 242/255, green: 143/255, blue: 155/255, alpha: 1.0)
    
    // Grey
    static let stoneGrey = UIColor(red: 196/255, green: 196/255, blue: 198/255, alpha: 1.0)
    static let dullGrey = UIColor(red: 138/255, green: 138/255, blue: 142/255, alpha: 1.0)
    static let defaultGrey = UIColor(red: 220/255, green: 220/255, blue: 221/255, alpha: 1.0)
    static let paleGray = UIColor(red: 242/255, green: 242/255, blue: 247/255, alpha: 1.0)
    static let separatorGrey = UIColor(red: 60/255, green: 60/255, blue: 67/255, alpha: 0.3)
    static let textGrey = UIColor(red: 60/255, green: 60/255, blue: 67/255, alpha: 0.7)
    
    static let darkStoneGrey = UIColor(red: 101/255, green: 101/255, blue: 106/255, alpha: 1.0)
    static let darkDullGrey = UIColor(red: 158/255, green: 158/255, blue: 165/255, alpha: 1.0)
    static let darkDefaultGrey = UIColor(red: 117/255, green: 117/255, blue: 117/255, alpha: 1.0)
    
    // Green
    static let addGreen = UIColor(red: 52/255, green: 199/255, blue: 89/255, alpha: 1.0)
    static let darkAddGreen = UIColor(red: 50/255, green: 215/255, blue: 75/255, alpha: 1.0)
    
    // Blue
    static let okayBlue = UIColor(red: 0, green: 113/255, blue: 255/255, alpha: 1.0)
    static let darkOkayBlue = UIColor(red: 10/255, green: 132/255, blue: 255/255, alpha: 1.0)

    // Old Color
    static let gradientPink = UIColor(red:0.85, green:0.20, blue:0.42, alpha:1.0)
    static let gradientRed = UIColor(red:0.88, green:0.21, blue:0.21, alpha:1.0)
    static let customPink = UIColor(red:0.84, green:0.10, blue:0.25, alpha:1.0)
    static let customGray = UIColor(red:0.61, green:0.61, blue:0.61, alpha:1.0)
    static let hasAccepted = UIColor(red:0.00, green:0.48, blue:1.00, alpha:1.0)
    static let hasDeclined = UIColor(red:0.82, green:0.01, blue:0.11, alpha:1.0)
    static let newGradientPink = UIColor(red: 255/255, green: 111/255, blue: 133/255, alpha: 1.0)
    static let newGradientRed = UIColor(red: 255/255, green: 73/255, blue: 72/255, alpha: 1.0)
    static let customBlue = UIColor(displayP3Red: 0/255, green: 165/255, blue: 255/255, alpha: 1.0)
    static let inputGray = UIColor(red: 208/255, green: 210/255, blue: 216/255, alpha: 1.0)
}


//extension UIColor {
//  @nonobjc class var soBlack: UIColor {
//    return UIColor(white: 0.0, alpha: 1.0)
//  }
//  @nonobjc class var allWhite: UIColor {
//    return UIColor(white: 1.0, alpha: 1.0)
//  }
//  @nonobjc class var okayBlue: UIColor {
//    return UIColor(red: 0.0, green: 113.0 / 255.0, blue: 1.0, alpha: 1.0)
//  }
//  @nonobjc class var justNoRed: UIColor {
//    return UIColor(red: 1.0, green: 59.0 / 255.0, blue: 48.0 / 255.0, alpha: 1.0)
//  }
//  @nonobjc class var dullGrey: UIColor {
//    return UIColor(red: 138.0 / 255.0, green: 138.0 / 255.0, blue: 142.0 / 255.0, alpha: 1.0)
//  }
//  @nonobjc class var stoneGrey: UIColor {
//    return UIColor(red: 196.0 / 255.0, green: 196.0 / 255.0, blue: 198.0 / 255.0, alpha: 1.0)
//  }
//  @nonobjc class var defaultGrey: UIColor {
//    return UIColor(red: 220.0 / 255.0, green: 220.0 / 255.0, blue: 221.0 / 255.0, alpha: 1.0)
//  }
//  @nonobjc class var paleGray: UIColor {
//    return UIColor(red: 242.0 / 255.0, green: 242.0 / 255.0, blue: 247.0 / 255.0, alpha: 1.0)
//  }
//  @nonobjc class var peachPink: UIColor {
//    return UIColor(red: 242.0 / 255.0, green: 120.0 / 255.0, blue: 135.0 / 255.0, alpha: 1.0)
//  }
//  @nonobjc class var highlightRed: UIColor {
//    return UIColor(red: 242.0 / 255.0, green: 89.0 / 255.0, blue: 82.0 / 255.0, alpha: 1.0)
//  }
//  @nonobjc class var addGreen: UIColor {
//    return UIColor(red: 52.0 / 255.0, green: 199.0 / 255.0, blue: 89.0 / 255.0, alpha: 1.0)
//  }
//  @nonobjc class var darkOkayBlue: UIColor {
//    return UIColor(red: 10.0 / 255.0, green: 132.0 / 255.0, blue: 1.0, alpha: 1.0)
//  }
//  @nonobjc class var darkJustNoRed: UIColor {
//    return UIColor(red: 1.0, green: 69.0 / 255.0, blue: 58.0 / 255.0, alpha: 1.0)
//  }
//  @nonobjc class var darkDullGrey: UIColor {
//    return UIColor(red: 158.0 / 255.0, green: 158.0 / 255.0, blue: 165.0 / 255.0, alpha: 1.0)
//  }
//  @nonobjc class var darkDefaultGrey: UIColor {
//    return UIColor(white: 117.0 / 255.0, alpha: 1.0)
//  }
//  @nonobjc class var darkStoneGrey: UIColor {
//    return UIColor(red: 101.0 / 255.0, green: 101.0 / 255.0, blue: 106.0 / 255.0, alpha: 1.0)
//  }
//  @nonobjc class var darkPeachPink: UIColor {
//    return UIColor(red: 242.0 / 255.0, green: 143.0 / 255.0, blue: 155.0 / 255.0, alpha: 1.0)
//  }
//  @nonobjc class var darkHighlightRed: UIColor {
//    return UIColor(red: 242.0 / 255.0, green: 99.0 / 255.0, blue: 92.0 / 255.0, alpha: 1.0)
//  }
//  @nonobjc class var darkAddGreen: UIColor {
//    return UIColor(red: 50.0 / 255.0, green: 215.0 / 255.0, blue: 75.0 / 255.0, alpha: 1.0)
//  }
//}
