//
//  UIImage.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Alex Cheung on 21/2/2020.
//  Copyright © 2020 Eric Ordonneau. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    /// Inverts the colors from the current image. Black turns white, white turns black etc.
    func invertedColors() -> UIImage? {
        guard let ciImage = CIImage(image: self) ?? ciImage, let filter = CIFilter(name: "CIColorInvert") else { return nil }
        filter.setValue(ciImage, forKey: kCIInputImageKey)

        guard let outputImage = filter.outputImage else { return nil }
        return UIImage(ciImage: outputImage)
    }
}
