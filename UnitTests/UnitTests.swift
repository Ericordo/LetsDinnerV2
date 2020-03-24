//
//  UnitTests.swift
//  UnitTests
//
//  Created by Alex Cheung on 23/3/2020.
//  Copyright © 2020 Eric Ordonneau. All rights reserved.
//

import XCTest

@testable import Let_s_Dinner_
//@testable import Pods_LetsDinnerV2
//@testable import Pods_LetsDinnerV2_MessagesExtension

class SampleUnitTests: XCTestCase {
    
    func sampleTest2() {
        let a = 1
        let b = 1
        XCTAssertEqual(a,b)
    }
}

class IntExtensionTests: XCTestCase {
    
    func testSquare() {
        let value = 3
        let squaredValue = value.square()
        XCTAssertEqual(squaredValue , 9)
        
    }
}


