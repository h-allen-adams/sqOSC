//
//  SqMixerMessages.swift
//  sqOSCTests
//
//  Created by H Allen Adams on 7/5/24.
//

@testable import sqOSC
import XCTest

final class SqMixerMessagesTests: XCTestCase {
    private var mixerMessages = SqMixerMessages()

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testMuteMessage() throws {
        XCTAssertEqual(mixerMessages.muteMessage(midiChannel: 1, type: SqChannelType.input, channel: 1, action: SqMuteAction.ON), "B0 63 00 B0 62 00 B0 06 00 B0 26 01")
        XCTAssertEqual(mixerMessages.muteMessage(midiChannel: 1, type: SqChannelType.main, channel: 1, action: SqMuteAction.OFF), "B0 63 00 B0 62 44 B0 06 00 B0 26 00")
        XCTAssertEqual(mixerMessages.muteMessage(midiChannel: 7, type: SqChannelType.muteGroup, channel: 4, action: SqMuteAction.ON), "B6 63 04 B6 62 03 B6 06 00 B6 26 01")
        XCTAssertEqual(mixerMessages.muteMessage(midiChannel: 1, type: SqChannelType.input, channel: 1, action: SqMuteAction.TOGGLE), "B0 63 00 B0 62 00 B0 60 00")
    }
}
