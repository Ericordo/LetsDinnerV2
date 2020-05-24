//
//  LDError.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 16/05/2020.
//  Copyright © 2020 Eric Ordonneau. All rights reserved.
//

import Foundation

enum LDError : Error {
    case noUserIdentifier
    case eventUploadFail
    case parsingFail
    case eventFetchingFail
    case profilePicUploadFail
}

#warning("Write descriptions")
extension LDError {
    var description : String {
        switch self {
        case .noUserIdentifier:
            return ""
        case .eventUploadFail:
            return ""
        case .parsingFail:
            return ""
        case .eventFetchingFail:
            return ""
        case .profilePicUploadFail:
            return ""
        }
    }
}
