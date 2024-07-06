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

    func testLinearFader() throws {
        expectLinearFader(dbLevel: -90, vce: "00", vfe: "00")
        expectLinearFader(dbLevel: -89, vce: "24", vfe: "16")
        expectLinearFader(dbLevel: -80, vce: "2C", vfe: "42")
        expectLinearFader(dbLevel: -60, vce: "3F", vfe: "09")
        expectLinearFader(dbLevel: -40, vce: "51", vfe: "4F")
        expectLinearFader(dbLevel: -20, vce: "64", vfe: "15")
        expectLinearFader(dbLevel: 0, vce: "76", vfe: "5C")
        expectLinearFader(dbLevel: 10, vce: "7F", vfe: "7F")
    }

    func testMuteMessage() throws {
        XCTAssertEqual(mixerMessages.muteMessage(midiChannel: 1, type: EndpointType.input, channel: 1, action: SqMuteAction.ON), "B0 63 00 B0 62 00 B0 06 00 B0 26 01")
        XCTAssertEqual(mixerMessages.muteMessage(midiChannel: 1, type: EndpointType.main, channel: 1, action: SqMuteAction.OFF), "B0 63 00 B0 62 44 B0 06 00 B0 26 00")
        XCTAssertEqual(mixerMessages.muteMessage(midiChannel: 7, type: EndpointType.muteGroup, channel: 4, action: SqMuteAction.ON), "B6 63 04 B6 62 03 B6 06 00 B6 26 01")
        XCTAssertEqual(mixerMessages.muteMessage(midiChannel: 1, type: EndpointType.input, channel: 1, action: SqMuteAction.TOGGLE), "B0 63 00 B0 62 00 B0 60 00")
    }

    func testSendLevelMessage() throws {
        XCTAssertEqual(mixerMessages.sendLevelMessage(midiChannel: 1, sourceType: EndpointType.input, sourceChannel: 1,
                                                      destType: EndpointType.main, destChannel: 1, dbLevel: 0), "B0 63 40 B0 62 00 B0 06 76 B0 26 5C")
        XCTAssertEqual(mixerMessages.sendLevelMessage(midiChannel: 1, sourceType: EndpointType.input, sourceChannel: 1,
                                                      destType: EndpointType.main, destChannel: 1, dbLevel: -20), "B0 63 40 B0 62 00 B0 06 64 B0 26 15")
        XCTAssertEqual(mixerMessages.sendLevelMessage(midiChannel: 1, sourceType: EndpointType.input, sourceChannel: 40,
                                                      destType: EndpointType.main, destChannel: 1, dbLevel: -20), "B0 63 40 B0 62 27 B0 06 64 B0 26 15")
        XCTAssertEqual(mixerMessages.sendLevelMessage(midiChannel: 1, sourceType: EndpointType.input, sourceChannel: 40,
                                                      destType: EndpointType.aux, destChannel: 5, dbLevel: -20), "B0 63 44 B0 62 1C B0 06 64 B0 26 15")
        XCTAssertEqual(mixerMessages.sendLevelMessage(midiChannel: 4, sourceType: EndpointType.input, sourceChannel: 40,
                                                      destType: EndpointType.aux, destChannel: 5, dbLevel: -12), "B3 63 44 B3 62 1C B3 06 6B B3 26 4B")
        XCTAssertEqual(mixerMessages.sendLevelMessage(midiChannel: 4, sourceType: EndpointType.group, sourceChannel: 4,
                                                      destType: EndpointType.aux, destChannel: 8, dbLevel: -24), "B3 63 45 B3 62 2F B3 06 60 B3 26 3B")
        XCTAssertEqual(mixerMessages.sendLevelMessage(midiChannel: 14, sourceType: EndpointType.input, sourceChannel: 36,
                                                      destType: EndpointType.fxSend, destChannel: 3, dbLevel: -12), "BD 63 4D BD 62 22 BD 06 6B BD 26 4B")
    }

    func testSoftKeyMessage() throws {
        XCTAssertEqual(mixerMessages.softKeyMessage(midiChannel: 1, button: 1, state: SqButtonState.PRESS), "90 30 7F")
        XCTAssertEqual(mixerMessages.softKeyMessage(midiChannel: 1, button: 1, state: SqButtonState.RELEASE), "80 30 00")
        XCTAssertEqual(mixerMessages.softKeyMessage(midiChannel: 5, button: 7, state: SqButtonState.PRESS), "94 36 7F")
        XCTAssertEqual(mixerMessages.softKeyMessage(midiChannel: 5, button: 7, state: SqButtonState.RELEASE), "84 36 00")
    }

    private func expectLinearFader(dbLevel: Int, vce: String, vfe: String) {
        let (vca, vfa) = mixerMessages.linearFader(dbLevel: dbLevel)
        XCTAssertEqual(vca, vce, "VC \(dbLevel) dB")
        XCTAssertEqual(vfa, vfe, "VF \(dbLevel) dB")
    }
}
