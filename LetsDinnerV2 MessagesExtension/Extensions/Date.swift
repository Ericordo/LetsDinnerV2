//
//  Date.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Alex Cheung on 23/2/2020.
//  Copyright © 2020 Eric Ordonneau. All rights reserved.
//

import Foundation

extension Date {
    static var currentTimeStamp: Int64{
        return Int64(Date().timeIntervalSince1970 * 1000)
    }
}

