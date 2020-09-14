//
//  SelectedRecipesViewModel.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 13/09/2020.
//  Copyright © 2020 Eric Ordonneau. All rights reserved.
//

import Foundation
import ReactiveSwift

class SelectedRecipesViewModel {
    
    let totalNumberOfRecipes : MutableProperty<Int>
    
    init() {
        totalNumberOfRecipes = MutableProperty(Event.shared.selectedRecipes.count + Event.shared.selectedCustomRecipes.count)
    }
    
    func updateTotalNumber() {
        totalNumberOfRecipes.value = Event.shared.selectedRecipes.count + Event.shared.selectedCustomRecipes.count
    }
    
}
