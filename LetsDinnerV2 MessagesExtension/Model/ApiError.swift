//
//  ApiError.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 17/11/2019.
//  Copyright © 2019 Eric Ordonneau. All rights reserved.
//

import Foundation

enum ApiError: Error {
    case requestLimit
    case noNetwork
    case decodingFailed
}
