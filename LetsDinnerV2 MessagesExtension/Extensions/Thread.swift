//
//  Thread.swift
//  LetsDinnerV2 MessagesExtension
//
//  Created by Alex Cheung on 28/2/2020.
//  Copyright © 2020 Eric Ordonneau. All rights reserved.
//

import Foundation

extension Thread {
    class func printCurrent() {
        print("\r⚡️: \(Thread.current)\r" + "🏭: \(OperationQueue.current?.underlyingQueue?.label ?? "None")\r")
    }
}
