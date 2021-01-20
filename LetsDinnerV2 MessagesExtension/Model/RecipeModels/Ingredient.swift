//
//  Ingredient.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 04/12/2019.
//  Copyright © 2019 Eric Ordonneau. All rights reserved.
//

import Foundation

struct Ingredient : Codable {
    var name: String?
    var metricAmount: Double?
    var usAmount: Double?
    var metricUnit : String?
    var usUnit: String?
}
