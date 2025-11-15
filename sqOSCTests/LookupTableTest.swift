//
//  LookupTableTest.swift
//  sqOSCTests
//
//  Created by H Allen Adams on 10/24/25.
//

@testable import sqOSC
import XCTest

final class LookupTableTest: XCTestCase {
    func testSqLevelValues_AudioTaper() throws {
        let mixerConfig = MixerConfig.load(.sq)
        let levelLookup = LookupTable(mixerConfig.levelParameterValues(.AudioTaper)!)

        XCTAssertEqual(toString(levelLookup.lookup(-100)), "00 00")
        XCTAssertEqual(toString(levelLookup.lookup(-95)), "00 73")
        XCTAssertEqual(toString(levelLookup.lookup(-90)), "01 40")
        XCTAssertEqual(toString(levelLookup.lookup(-89)), "01 50")
        XCTAssertEqual(toString(levelLookup.lookup(-80)), "02 60")
        XCTAssertEqual(toString(levelLookup.lookup(-60)), "06 00")
        XCTAssertEqual(toString(levelLookup.lookup(-40)), "0F 40")
        XCTAssertEqual(toString(levelLookup.lookup(-20)), "2E 40")
        XCTAssertEqual(toString(levelLookup.lookup(-10)), "3E 00")
        XCTAssertEqual(toString(levelLookup.lookup(0)), "62 00")
        XCTAssertEqual(toString(levelLookup.lookup(10)), "7F 40")
    }

    func testSqLevelValues_LinearTaper() throws {
        let mixerConfig = MixerConfig.load(.sq)
        let levelLookup = LookupTable(mixerConfig.levelParameterValues(.LinearTaper)!)

        XCTAssertEqual(toString(levelLookup.lookup(-100)), "00 00")
        XCTAssertEqual(toString(levelLookup.lookup(-95)), "00 00")
        XCTAssertEqual(toString(levelLookup.lookup(-90)), "00 00")
        XCTAssertEqual(toString(levelLookup.lookup(-89)), "24 16")
        XCTAssertEqual(toString(levelLookup.lookup(-80)), "2C 42")
        XCTAssertEqual(toString(levelLookup.lookup(-60)), "3F 09")
        XCTAssertEqual(toString(levelLookup.lookup(-40)), "51 4F")
        XCTAssertEqual(toString(levelLookup.lookup(-20)), "64 16")
        XCTAssertEqual(toString(levelLookup.lookup(-10)), "6D 39")
        XCTAssertEqual(toString(levelLookup.lookup(0)), "76 5C")
        XCTAssertEqual(toString(levelLookup.lookup(10)), "7F 7F")
    }

    func testCqLevelValues() throws {
        let mixerConfig = MixerConfig.load(.cq)
        let levelLookup = LookupTable(mixerConfig.levelParameterValues(.AudioTaper)!)

        XCTAssertEqual(toString(levelLookup.lookup(-100)), "00 00")
        XCTAssertEqual(toString(levelLookup.lookup(-95)), "00 73")
        XCTAssertEqual(toString(levelLookup.lookup(-90)), "01 40")
        XCTAssertEqual(toString(levelLookup.lookup(-89)), "01 50")
        XCTAssertEqual(toString(levelLookup.lookup(-80)), "02 60")
        XCTAssertEqual(toString(levelLookup.lookup(-60)), "06 00")
        XCTAssertEqual(toString(levelLookup.lookup(-40)), "0F 40")
        XCTAssertEqual(toString(levelLookup.lookup(-20)), "2E 40")
        XCTAssertEqual(toString(levelLookup.lookup(-10)), "3E 00")
        XCTAssertEqual(toString(levelLookup.lookup(0)), "62 00")
        XCTAssertEqual(toString(levelLookup.lookup(10)), "7F 40")
    }

    func testCqPanValues() throws {
        let mixerConfig = MixerConfig.load(.cq)
        let panLookup = LookupTable(mixerConfig.panParameterValues())

        XCTAssertEqual(toString(panLookup.lookup(-100)), "00 00")
        XCTAssertEqual(toString(panLookup.lookup(-90)), "06 33")
        XCTAssertEqual(toString(panLookup.lookup(-80)), "0C 66")
        XCTAssertEqual(toString(panLookup.lookup(-70)), "13 19")
        XCTAssertEqual(toString(panLookup.lookup(-60)), "19 4C")
        XCTAssertEqual(toString(panLookup.lookup(-50)), "1F 7F")
        XCTAssertEqual(toString(panLookup.lookup(-40)), "26 32")
        XCTAssertEqual(toString(panLookup.lookup(-35)), "29 4B")
        XCTAssertEqual(toString(panLookup.lookup(-30)), "2C 65")
        XCTAssertEqual(toString(panLookup.lookup(-20)), "33 18")
        XCTAssertEqual(toString(panLookup.lookup(-15)), "36 32")
        XCTAssertEqual(toString(panLookup.lookup(-10)), "39 4B")
        XCTAssertEqual(toString(panLookup.lookup(-5)), "3C 65")

        XCTAssertEqual(toString(panLookup.lookup(0)), "40 00")

        XCTAssertEqual(toString(panLookup.lookup(5)), "43 18")
        XCTAssertEqual(toString(panLookup.lookup(10)), "46 32")
        XCTAssertEqual(toString(panLookup.lookup(15)), "49 4B")
        XCTAssertEqual(toString(panLookup.lookup(20)), "4C 65")
        XCTAssertEqual(toString(panLookup.lookup(30)), "53 18")
        XCTAssertEqual(toString(panLookup.lookup(35)), "56 31")
        XCTAssertEqual(toString(panLookup.lookup(40)), "59 4B")
        XCTAssertEqual(toString(panLookup.lookup(50)), "5F 7F")
        XCTAssertEqual(toString(panLookup.lookup(60)), "66 32")
        XCTAssertEqual(toString(panLookup.lookup(70)), "6C 65")
        XCTAssertEqual(toString(panLookup.lookup(80)), "73 18")
        XCTAssertEqual(toString(panLookup.lookup(90)), "79 4B")
        XCTAssertEqual(toString(panLookup.lookup(100)), "7F 7F")
    }

    private func toString(_ value: Int) -> String {
        let (msb, lsb) = Values.toMsbLsb(value)
        return "\(msb) \(lsb)"
    }
}
