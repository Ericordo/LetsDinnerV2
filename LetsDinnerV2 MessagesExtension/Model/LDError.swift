//
//  LDError.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 16/05/2020.
//  Copyright © 2020 Eric Ordonneau. All rights reserved.
//

import Foundation

enum LDError : Error {
    case genericError
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
    case remindersDenied
    case statusUpdateFail
    case taskUpdateFail
    case recipeNameMissing
    case recipeSaveCloudFail
    case recipePicUploadFail
    case recipeUpdateCloudFail
    case recipeDeleteCloudFail
    case notSignedInCloud
    case apiRequestLimit
    case noNetwork
    case apiDecodingFailed
}

#warning("Write descriptions")
extension LDError {
    var description : String {
        switch self {
        case .genericError:
            return ""
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
        case .remindersDenied:
            return AlertStrings.remindersDenied
        case .statusUpdateFail:
            return ""
        case .taskUpdateFail:
            return ""
        case .recipeNameMissing:
            return ""
        case .recipeSaveCloudFail:
            return ""
        case .recipePicUploadFail:
            return AlertStrings.saveImageErrorMessage
        case .recipeUpdateCloudFail:
            return ""
        case .recipeDeleteCloudFail:
            return ""
        case .notSignedInCloud:
            return ""
        case .apiRequestLimit:
            #warning("Improve error messages for next 3 messages")
            return AlertStrings.requestLimit
        case .noNetwork:
            return AlertStrings.noNetwork
        case .apiDecodingFailed:
            return AlertStrings.decodingFailed
        }
    }
}
