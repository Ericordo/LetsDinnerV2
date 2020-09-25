//
//  Date.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Alex Cheung on 23/2/2020.
//  Copyright © 2020 Eric Ordonneau. All rights reserved.
//

import Foundation

extension Date {
    #warning("To delete before release, just used for test")
    static var currentTimeStamp: Int64 {
        var dateComponents = DateComponents()
        dateComponents.year = 2020
        dateComponents.month = 12
        dateComponents.day = 31
        dateComponents.timeZone = TimeZone(abbreviation: "JST") // Japan Standard Time
        dateComponents.hour = 8
        dateComponents.minute = 30
        
        let userCalendar = Calendar.current
        let someDateTime = userCalendar.date(from: dateComponents)
        
        return Int64(someDateTime!.timeIntervalSince1970)
//        return Int64(Date().timeIntervalSince1970 * 1000 + 1000)
    }
}

