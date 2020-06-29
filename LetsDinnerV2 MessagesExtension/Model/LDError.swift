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
    case recipeSaveRealmFail
    case deleteRealmContentFail
    case transferToRealmFail
    case recipeUpdateRealmFail
    case recipeDeleteRealmFail
    case addToCalendarFail
    case calendarDenied
}

#warning("Write descriptions")
extension LDError {
    var description : String {
        switch self {
        case .noUserIdentifier:
            return ""
        case .eventUploadFail:
            return AlertStrings.eventUploadFail
        case .parsingFail:
            return ""
        case .eventFetchingFail:
            return AlertStrings.eventFetchingFail
        case .profilePicUploadFail:
            return ""
        case .recipeSaveRealmFail:
            return ""
        case .deleteRealmContentFail:
            return ""
        case .transferToRealmFail:
            return ""
        case .recipeUpdateRealmFail:
            return ""
        case .recipeDeleteRealmFail:
            return ""
        case .addToCalendarFail:
            return ""
        case .calendarDenied:
            return AlertStrings.calendarDenied
        }
    }
}
