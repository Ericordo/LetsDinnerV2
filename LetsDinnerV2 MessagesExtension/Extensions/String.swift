//
//  String.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Eric Ordonneau on 05/11/2019.
//  Copyright © 2019 Eric Ordonneau. All rights reserved.
//

import Foundation

// MARK: String Helper
// Example = EX
// For Example = FE
// for example = FE
// "" = ??

extension String {
    
    public var initials: String {
        
        let words = components(separatedBy: .whitespacesAndNewlines)
        
        //to identify letters
        let letters = CharacterSet.letters
        var firstChar : String = ""
        var secondChar : String = ""
        var firstCharFoundIndex : Int = -1
        var firstCharFound : Bool = false
        var secondCharFound : Bool = false
        
        for (index, item) in words.enumerated() {
            
            if item.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                continue
            }
            
            //browse through the rest of the word
            for (_, char) in item.unicodeScalars.enumerated() {
                
                //check if its a aplha
                if letters.contains(char) {
                    
                    if !firstCharFound {
                        firstChar = String(char).capitalized
                        firstCharFound = true
                        firstCharFoundIndex = index
                        
                    } else if !secondCharFound {
                        
                        secondChar = String(char).capitalized
                        if firstCharFoundIndex != index {
                            secondCharFound = true
                        }
                        
                        break
                    } else {
                        break
                    }
                }
            }
        }
        
        if firstChar.isEmpty && secondChar.isEmpty {
            firstChar = "?"
            secondChar = ""
        }
        
        return firstChar + secondChar
    }
}


