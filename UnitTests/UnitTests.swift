//
//  UnitTests.swift
//  UnitTests
//
//  Created by Alex Cheung on 23/3/2020.
//  Copyright © 2020 Eric Ordonneau. All rights reserved.
//

import XCTest

@testable import Let_s_Dinner_

class UnitTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func sampleTest() {
        let a = 1
        let b = 1
        
        XCTAssertEqual(a, b)
    }

}
