//
//  UIImageView.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 08/11/2019.
//  Copyright © 2019 Eric Ordonneau. All rights reserved.
//

import UIKit

extension UIImageView {
    
    /// Sets the image property of the view based on initial text, a specified background color, custom text attributes, and a circular clipping
    ///
    /// - Parameters:
    ///   - string: The string used to generate the initials. This should be a user's full name if available.
    ///   - color: This optional paramter sets the background of the image. By default, a random color will be generated.
    ///   - circular: This boolean will determine if the image view will be clipped to a circular shape.
    ///   - textAttributes: This dictionary allows you to specify font, text color, shadow properties, etc.
    
    open func setImage(string: String?,
                       color: UIColor? = nil,
                       circular: Bool = false,
                       stroke: Bool = false,
                       strokeColor: UIColor,
                       textAttributes: [NSAttributedString.Key: Any]? = nil) {
        
        let image = imageSnap(text: string != nil ? string?.initials : "",
                              color: color ?? .black,
                              circular: circular,
                              stroke: stroke,
                              strokeColor: strokeColor,
                              textAttributes:textAttributes)
        
        if let newImage = image {
            self.image = newImage
        }
    }
    
    private func imageSnap(text: String?,
                           color: UIColor,
                           circular: Bool,
                           stroke: Bool,
                           strokeColor: UIColor,
                           textAttributes: [NSAttributedString.Key: Any]?) -> UIImage? {
        
        let scale = Float(UIScreen.main.scale)
        var size = bounds.size
        if contentMode == .scaleToFill || contentMode == .scaleAspectFill || contentMode == .scaleAspectFit || contentMode == .redraw {
            size.width = CGFloat(floorf((Float(size.width) * scale) / scale))
            size.height = CGFloat(floorf((Float(size.height) * scale) / scale))
        }
        
        UIGraphicsBeginImageContextWithOptions(size, false, CGFloat(scale))
        let context = UIGraphicsGetCurrentContext()
        if circular {
            let path = CGPath(ellipseIn: bounds, transform: nil)
            context?.addPath(path)
            context?.clip()
        }
        
        // Fill
        
        context?.setFillColor(color.cgColor)
        context?.fill(CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        let attributes = textAttributes ?? [NSAttributedString.Key.foregroundColor: UIColor.white,
                                            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 55.0)]
        
        
        //stroke color
        if stroke {
            
            //outer circle
            context?.setStrokeColor(strokeColor.cgColor)
            context?.setLineWidth(4)
            let rectangle : CGRect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            context?.addEllipse(in: rectangle)
            context?.drawPath(using: .fillStroke)
            
            //inner circle
            //            context?.setLineWidth(1)
            //            rectangle = CGRect(x: 4, y: 4, width: size.width - 8, height: size.height - 8)
            //            context?.addEllipse(in: rectangle)
            //            context?.drawPath(using: .fillStroke)
        }
        
        // Text
        if let text = text {
            let textSize = text.size(withAttributes: attributes)
            let bounds = self.bounds
            let rect = CGRect(x: bounds.size.width/2 - textSize.width/2, y: bounds.size.height/2 - textSize.height/2, width: textSize.width, height: textSize.height)
            
            text.draw(in: rect, withAttributes: attributes)
        }
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
}
