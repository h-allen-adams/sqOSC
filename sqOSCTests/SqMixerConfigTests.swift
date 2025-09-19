//
//  SqMixerEndpointsTest.swift
//  sqOSCTests
//
//  Created by H Allen Adams on 7/5/24.
//

@testable import sqOSC
import XCTest

final class SqMixerConfigTest: XCTestCase {
    let mixerConfig = SqMixerConfig.singletonInstance()

    func testEndpointCounts() throws {
        XCTAssertEqual(mixerConfig.channelCount(.aux), 12)
    }

    func testChannelSupports() throws {
        XCTAssertTrue(mixerConfig.channelSupports(.mute, .input))
        XCTAssertTrue(mixerConfig.channelSupports(.level, .matrix))
        XCTAssertTrue(mixerConfig.channelSupports(.balance, .aux))
        XCTAssertTrue(mixerConfig.channelSupports(.sendLevel, .input))
        XCTAssertFalse(mixerConfig.channelSupports(.level, .input))
    }

    func testSimpleParameters() throws {
        XCTAssertEqual(mixerConfig.channelParameter(.mute, .input)!, Values.toParameterNumber("00", "00"))
        XCTAssertEqual(mixerConfig.channelParameter(.level, .matrix)!, Values.toParameterNumber("4F", "11"))
        XCTAssertEqual(mixerConfig.channelParameter(.balance, .aux)!, Values.toParameterNumber("5F", "01"))
    }

    func testChannelTargets() throws {
        let inputTargets = mixerConfig.channelTargets(.sendLevel, source: .input)
        XCTAssertEqual(inputTargets.count, 3)
        XCTAssertTrue(inputTargets.contains(.aux))
        XCTAssertTrue(inputTargets.contains(.main))
        XCTAssertTrue(inputTargets.contains(.fxSend))

        let mainTargets = mixerConfig.channelTargets(.sendLevel, source: .main)
        XCTAssertEqual(mainTargets.count, 1)
        XCTAssertTrue(mainTargets.contains(.matrix))
    }

    func testSourceDestParameters() throws {
        XCTAssertEqual(mixerConfig.channelToChannelParameter(.sendLevel, source: .input, dest: .main)!,
                       Values.toParameterNumber("40", "00"))
        XCTAssertEqual(mixerConfig.channelToChannelParameter(.pan, source: .main, dest: .matrix)!,
                       Values.toParameterNumber("5E", "24"))
    }
}
