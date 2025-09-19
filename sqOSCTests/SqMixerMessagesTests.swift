//
//  SqMixerMessages.swift
//  sqOSCTests
//
//  Created by H Allen Adams on 7/5/24.
//

import MIDIKitCore
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
        XCTAssertEqual(toString(mixerMessages.muteMessage(midiChannel: 1, type: EndpointType.input, channel: 1, action: SqMuteAction.ON)),
                       "B0 63 00 B0 62 00 B0 06 00 B0 26 01")
        XCTAssertEqual(toString(mixerMessages.muteMessage(midiChannel: 1, type: EndpointType.main, channel: 1, action: SqMuteAction.OFF)),
                       "B0 63 00 B0 62 44 B0 06 00 B0 26 00")
        XCTAssertEqual(toString(mixerMessages.muteMessage(midiChannel: 7, type: EndpointType.muteGroup, channel: 4, action: SqMuteAction.ON)),
                       "B6 63 04 B6 62 03 B6 06 00 B6 26 01")
//        XCTAssertEqual(toString(mixerMessages.muteMessage(midiChannel: 1, type: EndpointType.input, channel: 1, action: SqMuteAction.TOGGLE)),
//                       "B0 63 00 B0 62 00 B0 60 00")
    }

    func testSendLevelMessage() throws {
        XCTAssertEqual(toString(mixerMessages.sendLevelMessage(midiChannel: 1, sourceType: EndpointType.input, sourceChannel: 1,
                                                               destType: EndpointType.main, destChannel: 1, dbLevel: 0)),
                       "B0 63 40 B0 62 00 B0 06 76 B0 26 5C")
        XCTAssertEqual(toString(mixerMessages.sendLevelMessage(midiChannel: 1, sourceType: EndpointType.input, sourceChannel: 1,
                                                               destType: EndpointType.main, destChannel: 1, dbLevel: -20)),
                       "B0 63 40 B0 62 00 B0 06 64 B0 26 15")
        XCTAssertEqual(toString(mixerMessages.sendLevelMessage(midiChannel: 1, sourceType: EndpointType.input, sourceChannel: 40,
                                                               destType: EndpointType.main, destChannel: 1, dbLevel: -20)),
                       "B0 63 40 B0 62 27 B0 06 64 B0 26 15")
        XCTAssertEqual(toString(mixerMessages.sendLevelMessage(midiChannel: 1, sourceType: EndpointType.input, sourceChannel: 40,
                                                               destType: EndpointType.aux, destChannel: 5, dbLevel: -20)),
                       "B0 63 44 B0 62 1C B0 06 64 B0 26 15")
        XCTAssertEqual(toString(mixerMessages.sendLevelMessage(midiChannel: 4, sourceType: EndpointType.input, sourceChannel: 40,
                                                               destType: EndpointType.aux, destChannel: 5, dbLevel: -12)),
                       "B3 63 44 B3 62 1C B3 06 6B B3 26 4B")
        XCTAssertEqual(toString(mixerMessages.sendLevelMessage(midiChannel: 4, sourceType: EndpointType.group, sourceChannel: 4,
                                                               destType: EndpointType.aux, destChannel: 8, dbLevel: -24)),
                       "B3 63 45 B3 62 2F B3 06 60 B3 26 3B")
        XCTAssertEqual(toString(mixerMessages.sendLevelMessage(midiChannel: 14, sourceType: EndpointType.input, sourceChannel: 36,
                                                               destType: EndpointType.fxSend, destChannel: 3, dbLevel: -12)),
                       "BD 63 4D BD 62 22 BD 06 6B BD 26 4B")
    }

    func testPanMessage() throws {
        XCTAssertEqual(toString(mixerMessages.sendPanMessage(midiChannel: 1, sourceType: EndpointType.input, sourceChannel: 1,
                                                             destType: EndpointType.main, destChannel: 1, panLevel: -100)),
                       "B0 63 50 B0 62 00 B0 06 00 B0 26 00")
        XCTAssertEqual(toString(mixerMessages.sendPanMessage(midiChannel: 1, sourceType: EndpointType.input, sourceChannel: 1,
                                                             destType: EndpointType.main, destChannel: 1, panLevel: 0)),
                       "B0 63 50 B0 62 00 B0 06 3F B0 26 7F")
        XCTAssertEqual(toString(mixerMessages.sendPanMessage(midiChannel: 1, sourceType: EndpointType.input, sourceChannel: 24,
                                                             destType: EndpointType.main, destChannel: 1, panLevel: 20)),
                       "B0 63 50 B0 62 17 B0 06 4C B0 26 65")
        XCTAssertEqual(toString(mixerMessages.sendPanMessage(midiChannel: 1, sourceType: EndpointType.input, sourceChannel: 24,
                                                             destType: EndpointType.aux, destChannel: 5, panLevel: 20)),
                       "B0 63 52 B0 62 5C B0 06 4C B0 26 65")
        XCTAssertEqual(toString(mixerMessages.sendPanMessage(midiChannel: 4, sourceType: EndpointType.input, sourceChannel: 24,
                                                             destType: EndpointType.aux, destChannel: 5, panLevel: -50)),
                       "B3 63 52 B3 62 5C B3 06 1F B3 26 7F")
        XCTAssertEqual(toString(mixerMessages.sendPanMessage(midiChannel: 4, sourceType: EndpointType.group, sourceChannel: 3,
                                                             destType: EndpointType.aux, destChannel: 2, panLevel: -50)),
                       "B3 63 55 B3 62 1D B3 06 1F B3 26 7F")
        XCTAssertEqual(toString(mixerMessages.sendPanMessage(midiChannel: 11, sourceType: EndpointType.main, sourceChannel: 1,
                                                             destType: EndpointType.matrix, destChannel: 3, panLevel: 100)),
                       "BA 63 5E BA 62 26 BA 06 7F BA 26 7E")
    }

    func testSoftKeyMessage() throws {
        XCTAssertEqual(toString(mixerMessages.softKeyMessage(midiChannel: 1, button: 1, state: SqButtonState.PRESS)), "90 30 7F")
        XCTAssertEqual(toString(mixerMessages.softKeyMessage(midiChannel: 1, button: 1, state: SqButtonState.RELEASE)), "80 30 00")
        XCTAssertEqual(toString(mixerMessages.softKeyMessage(midiChannel: 5, button: 7, state: SqButtonState.PRESS)), "94 36 7F")
        XCTAssertEqual(toString(mixerMessages.softKeyMessage(midiChannel: 5, button: 7, state: SqButtonState.RELEASE)), "84 36 00")
    }

    private func expectLinearFader(dbLevel: Int, vce: String, vfe: String) {
        let pv = mixerMessages.linearFader(dbLevel: dbLevel)
        let (vca, vfa) = (Values.decToHex(pv / 128), Values.decToHex(pv % 128))
        XCTAssertEqual(vca, vce, "VC \(dbLevel) dB")
        XCTAssertEqual(vfa, vfe, "VF \(dbLevel) dB")
    }

    private func toString(_ event: MIDIEvent?) -> String {
        return MidiMessagePublisher.toString(event)
    }
}
