//
//  EventDescriptionViewModel.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 12/05/2020.
//  Copyright © 2020 Eric Ordonneau. All rights reserved.
//

import Foundation
import ReactiveSwift

class EventDescriptionViewModel {
    
    let allRecipeTitles : [String]
    let description : MutableProperty<String>
    let maxCharsLength = 400
    
    init() {
        allRecipeTitles = CustomOrderHelper.shared.mergeAllRecipeTitlesInCustomOrder()
        description = MutableProperty(Event.shared.eventDescription)
    }
    
    
}
