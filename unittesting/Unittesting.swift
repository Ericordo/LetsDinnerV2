//
//  unittesting.swift
//  unittesting
//
//  Created by Alex Cheung on 18/3/2020.
//  Copyright © 2020 Eric Ordonneau. All rights reserved.
//

import XCTest

class EventTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        let temp = 123
        let temp2 = 234
        
        var total = temp + temp2
        XCTAssertEqual(total, 357)
        
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    

}
