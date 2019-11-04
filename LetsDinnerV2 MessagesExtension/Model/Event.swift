//
//  Event.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 04/11/2019.
//  Copyright © 2019 Eric Ordonneau. All rights reserved.
//

import Foundation

class Event {
    
    static let shared = Event()
    
    private init () {}
    
    var dinnerName = ""
    var hostName = ""
    var dinnerDate : String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, h:mm a"
        let date = Date(timeIntervalSince1970: dateTimestamp)
        let dateString = dateFormatter.string(from: date)
        return dateString
    }
    var dateTimestamp = Double()
    var dinnerLocation = "" 
    
    
}
