//
//  File.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Alex Cheung on 29/11/2019.
//  Copyright © 2019 Eric Ordonneau. All rights reserved.
//

import UIKit
import Foundation

// Initate all variable for event

class testCase {

    static func createCaseOne() -> Event {
        let event = Event()
        
        event.dinnerName = "Test Case 1 with a very long long long name"
        event.hostName = "Sexy Baby"
        event.eventDescription = "I am so curious what is happening in the kitchen with a French guy making lasagna with some bottle of milk ready to put some ginger into the pomodoro. Everyone keeps singing an American Song which called The victory of the Vitnamese having Pho for dinner drinking a huge tank of beer showing a very impatient face to the Koreans"
        event.dinnerLocation = "-18/F Basement"
        event.dateTimestamp = 0
        
        return event
    }
    
    private func grabRecipe() {
        
    }
}

