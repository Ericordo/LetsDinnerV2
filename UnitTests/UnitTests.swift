//
//  UnitTests.swift
//  UnitTests
//
//  Created by Alex Cheung on 23/3/2020.
//  Copyright © 2020 Eric Ordonneau. All rights reserved.
//

import XCTest
import UIKit

@testable import Let_s_Dinner_
@testable import Pods_LetsDinnerV2
@testable import Pods_LetsDinnerV2_MessagesExtension

class UnitTests: XCTestCase {
    
//    var controller: UIViewController!
//    var event: Event!
    
    override func setUp() {
        super.setUp()
        
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func sampleTest() {
        let value = 3
        let squaredValue = value.square()
        XCTAssertEqual(squaredValue , 9)
        
    }
    
    func sampleTest2() {
        let a = 1
        let b = 1
        XCTAssertEqual(a,b)
    }

}
