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

class IntUnitTests: XCTestCase {
    
    func sampleTest() {
        let value = 3
        let squaredValue = value.square()
        XCTAssertEqual(squaredValue , 9)
        
    }
}

class CreateEventUnitTest: XCTestCase {
    var vc: NewEventViewController!
    var event: Event!
    
    private func setUpViewController() {
//        let bundle = Bundle(for: CustomView.self)
//        guard let self.vc = bundle.loadNibNamed(VCNibs.newEventViewController, owner: self)?.first as? NewEventViewController else { return XCTFail("Could not instantiate vc from Main storyboard")}
//        self.vc = NewEventViewController(nibName: VCNibs.newEventViewController, bundle: nil)
//        self.vc.loadView ()
        self.vc.viewDidLoad()
    }
    
    override func setUp() {
        super.setUp()
        self.setUpViewController()
    }
    
    override func tearDown() {
        self.vc = nil
        super.tearDown()
    }
    
    func testUIComponentExists() {
        XCTAssert((self.vc != nil))
        XCTAssert((self.vc.hostNameTextField != nil))
    }
}
