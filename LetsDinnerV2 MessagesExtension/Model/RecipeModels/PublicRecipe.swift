//
//  PublicRecipe.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 06/01/2021.
//  Copyright © 2021 Eric Ordonneau. All rights reserved.
//

import Foundation

struct PublicRecipe {
    let recipe: LDRecipe
    let validated: Bool = false
    let language: String = "en"
}
