//
//  TuningForkTests.swift
//  TuningForkTests
//
//  Created by Comyar Zaheri on 11/8/15.
//  Copyright © 2015 Comyar Zaheri. All rights reserved.
//

import XCTest
@testable import TuningFork

class TuningForkTests: XCTestCase {
    
    func testOutput() {
        let output = Tuner.newOutput(440, 1.0)
        XCTAssertEqual(output.frequency, 440)
        XCTAssertEqual(output.octave, 4)
        XCTAssertEqual(output.amplitude, 1.0)
        XCTAssertEqual(output.pitch, "A")
        XCTAssertEqual(output.distance, 0)
    }
}
