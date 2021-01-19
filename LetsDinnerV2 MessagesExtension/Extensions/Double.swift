//
//  Double.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Alex Cheung on 27/6/2020.
//  Copyright © 2020 Eric Ordonneau. All rights reserved.
//

import Foundation

extension Double {
    var trailingZero: String {
       return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
    }
}
