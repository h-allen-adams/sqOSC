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
    private var mixerMessages = MixerMidiMessageFactory(mixerConfig: MixerConfig.load(.sq), faderLaw: .LinearTaper)

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testMuteMessage() throws {
        XCTAssertEqual(toString(mixerMessages.muteMessage(midiChannel: 1, type: .input, channel: 1, action: .ON)),
                       "B0 63 00 B0 62 00 B0 06 00 B0 26 01")
        XCTAssertEqual(toString(mixerMessages.muteMessage(midiChannel: 1, type: .main, channel: 1, action: .OFF)),
                       "B0 63 00 B0 62 44 B0 06 00 B0 26 00")
        XCTAssertEqual(toString(mixerMessages.muteMessage(midiChannel: 7, type: .muteGroup, channel: 4, action: .ON)),
                       "B6 63 04 B6 62 03 B6 06 00 B6 26 01")
//        XCTAssertEqual(toString(mixerMessages.muteMessage(midiChannel: 1, type: EndpointType.input, channel: 1, action: SqMuteAction.TOGGLE)),
//                       "B0 63 00 B0 62 00 B0 60 00")
    }

    func testSendLevelMessage() throws {
        XCTAssertEqual(toString(mixerMessages.sendLevelMessage(midiChannel: 1, sourceType: .input, sourceChannel: 1,
                                                               destType: .main, destChannel: 1, dbLevel: 0)),
                       "B0 63 40 B0 62 00 B0 06 76 B0 26 5C")
        XCTAssertEqual(toString(mixerMessages.sendLevelMessage(midiChannel: 1, sourceType: .input, sourceChannel: 1,
                                                               destType: .main, destChannel: 1, dbLevel: -20)),
                       "B0 63 40 B0 62 00 B0 06 64 B0 26 16")
        XCTAssertEqual(toString(mixerMessages.sendLevelMessage(midiChannel: 1, sourceType: .input, sourceChannel: 40,
                                                               destType: .main, destChannel: 1, dbLevel: -20)),
                       "B0 63 40 B0 62 27 B0 06 64 B0 26 16")
        XCTAssertEqual(toString(mixerMessages.sendLevelMessage(midiChannel: 1, sourceType: .input, sourceChannel: 40,
                                                               destType: .aux, destChannel: 5, dbLevel: -20)),
                       "B0 63 44 B0 62 1C B0 06 64 B0 26 16")
        XCTAssertEqual(toString(mixerMessages.sendLevelMessage(midiChannel: 4, sourceType: .input, sourceChannel: 40,
                                                               destType: .aux, destChannel: 5, dbLevel: -12)),
                       "B3 63 44 B3 62 1C B3 06 6B B3 26 4B")
        XCTAssertEqual(toString(mixerMessages.sendLevelMessage(midiChannel: 4, sourceType: .group, sourceChannel: 4,
                                                               destType: .aux, destChannel: 8, dbLevel: -24)),
                       "B3 63 45 B3 62 2F B3 06 60 B3 26 3B")
        XCTAssertEqual(toString(mixerMessages.sendLevelMessage(midiChannel: 14, sourceType: .input, sourceChannel: 36,
                                                               destType: .fxSend, destChannel: 3, dbLevel: -12)),
                       "BD 63 4D BD 62 22 BD 06 6B BD 26 4B")
    }

    func testPanMessage() throws {
        XCTAssertEqual(toString(mixerMessages.sendPanMessage(midiChannel: 1, sourceType: .input, sourceChannel: 1,
                                                             destType: .main, destChannel: 1, panLevel: -100)),
                       "B0 63 50 B0 62 00 B0 06 00 B0 26 00")
        XCTAssertEqual(toString(mixerMessages.sendPanMessage(midiChannel: 1, sourceType: .input, sourceChannel: 1,
                                                             destType: .main, destChannel: 1, panLevel: 0)),
                       "B0 63 50 B0 62 00 B0 06 3F B0 26 7F")
        XCTAssertEqual(toString(mixerMessages.sendPanMessage(midiChannel: 1, sourceType: .input, sourceChannel: 24,
                                                             destType: .main, destChannel: 1, panLevel: 20)),
                       "B0 63 50 B0 62 17 B0 06 4C B0 26 65")
        XCTAssertEqual(toString(mixerMessages.sendPanMessage(midiChannel: 1, sourceType: .input, sourceChannel: 24,
                                                             destType: .aux, destChannel: 5, panLevel: 20)),
                       "B0 63 52 B0 62 5C B0 06 4C B0 26 65")
        XCTAssertEqual(toString(mixerMessages.sendPanMessage(midiChannel: 4, sourceType: .input, sourceChannel: 24,
                                                             destType: .aux, destChannel: 5, panLevel: -50)),
                       "B3 63 52 B3 62 5C B3 06 1F B3 26 7F")
        XCTAssertEqual(toString(mixerMessages.sendPanMessage(midiChannel: 4, sourceType: .group, sourceChannel: 3,
                                                             destType: .aux, destChannel: 2, panLevel: -50)),
                       "B3 63 55 B3 62 1D B3 06 1F B3 26 7F")
        XCTAssertEqual(toString(mixerMessages.sendPanMessage(midiChannel: 11, sourceType: .main, sourceChannel: 1,
                                                             destType: .matrix, destChannel: 3, panLevel: 100)),
                       "BA 63 5E BA 62 26 BA 06 7F BA 26 7F")
    }

    func testSoftKeyMessage() throws {
        XCTAssertEqual(toString(mixerMessages.softKeyMessage(midiChannel: 1, button: 1, state: .PRESS)), "90 30 7F")
        XCTAssertEqual(toString(mixerMessages.softKeyMessage(midiChannel: 1, button: 1, state: .RELEASE)), "80 30 00")
        XCTAssertEqual(toString(mixerMessages.softKeyMessage(midiChannel: 5, button: 7, state: .PRESS)), "94 36 7F")
        XCTAssertEqual(toString(mixerMessages.softKeyMessage(midiChannel: 5, button: 7, state: .RELEASE)), "84 36 00")
    }

    func testMixAssignment() throws {
        XCTAssertEqual(toString(mixerMessages.assignMessage(midiChannel: 1,
                                                            sourceType: .input, sourceChannel: 1,
                                                            destType: .main, destChannel: 1, action: .ON)),
                       "B0 63 60 B0 62 00 B0 06 00 B0 26 01")
        XCTAssertEqual(toString(mixerMessages.assignMessage(midiChannel: 1,
                                                            sourceType: .input, sourceChannel: 1,
                                                            destType: .main, destChannel: 1, action: .OFF)),
                       "B0 63 60 B0 62 00 B0 06 00 B0 26 00")
        XCTAssertEqual(toString(mixerMessages.assignMessage(midiChannel: 1,
                                                            sourceType: .fxReturn, sourceChannel: 1,
                                                            destType: .aux, destChannel: 7, action: .ON)),
                       "B0 63 66 B0 62 1A B0 06 00 B0 26 01")
        XCTAssertEqual(toString(mixerMessages.assignMessage(midiChannel: 2,
                                                            sourceType: .group, sourceChannel: 1,
                                                            destType: .aux, destChannel: 3, action: .OFF)),
                       "B1 63 65 B1 62 06 B1 06 00 B1 26 00")
    }

    private func toString(_ event: MIDIEvent?) -> String {
        return MidiMessagePublisher.toString(event)
    }
}
