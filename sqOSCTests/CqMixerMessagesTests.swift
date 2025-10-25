//
//  SqMixerMessages.swift
//  sqOSCTests
//
//  Created by H Allen Adams on 7/5/24.
//

import MIDIKitCore
@testable import sqOSC
import XCTest

final class CqMixerMessagesTests: XCTestCase {
    private var mixerMessages = MixerMidiMessageFactory(mixerConfig: MixerConfig.load(.cq),
                                                        faderLaw: .AudioTaper)

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
                       "B0 63 40 B0 62 00 B0 06 62 B0 26 00")
        XCTAssertEqual(toString(mixerMessages.sendLevelMessage(midiChannel: 1, sourceType: .input, sourceChannel: 1,
                                                               destType: .main, destChannel: 1, dbLevel: -20)),
                       "B0 63 40 B0 62 00 B0 06 2E B0 26 40")
        XCTAssertEqual(toString(mixerMessages.sendLevelMessage(midiChannel: 1, sourceType: .input, sourceChannel: 40,
                                                               destType: .main, destChannel: 1, dbLevel: -20)),
                       "B0 63 40 B0 62 27 B0 06 2E B0 26 40")
        XCTAssertEqual(toString(mixerMessages.sendLevelMessage(midiChannel: 1, sourceType: .input, sourceChannel: 40,
                                                               destType: .aux, destChannel: 5, dbLevel: -20)),
                       "B0 63 42 B0 62 32 B0 06 2E B0 26 40")
        XCTAssertEqual(toString(mixerMessages.sendLevelMessage(midiChannel: 4, sourceType: .input, sourceChannel: 40,
                                                               destType: .aux, destChannel: 5, dbLevel: -12)),
                       "B3 63 42 B3 62 32 B3 06 3B B3 26 00")
        XCTAssertEqual(toString(mixerMessages.sendLevelMessage(midiChannel: 14, sourceType: .input, sourceChannel: 36,
                                                               destType: .fxSend, destChannel: 3, dbLevel: -12)),
                       "BD 63 4D BD 62 22 BD 06 3B BD 26 00")
    }

    func testPanMessage() throws {
        XCTAssertEqual(toString(mixerMessages.sendPanMessage(midiChannel: 1, sourceType: .input, sourceChannel: 1,
                                                             destType: .main, destChannel: 1, panLevel: -100)),
                       "B0 63 50 B0 62 00 B0 06 00 B0 26 00")
        XCTAssertEqual(toString(mixerMessages.sendPanMessage(midiChannel: 1, sourceType: .input, sourceChannel: 1,
                                                             destType: .main, destChannel: 1, panLevel: 0)),
                       "B0 63 50 B0 62 00 B0 06 40 B0 26 00")
        XCTAssertEqual(toString(mixerMessages.sendPanMessage(midiChannel: 1, sourceType: .input, sourceChannel: 16,
                                                             destType: .main, destChannel: 1, panLevel: 20)),
                       "B0 63 50 B0 62 0F B0 06 4C B0 26 65")
        XCTAssertEqual(toString(mixerMessages.sendPanMessage(midiChannel: 1, sourceType: .input, sourceChannel: 16,
                                                             destType: .aux, destChannel: 5, panLevel: 20)),
                       "B0 63 51 B0 62 22 B0 06 4C B0 26 65")
        XCTAssertEqual(toString(mixerMessages.sendPanMessage(midiChannel: 4, sourceType: .input, sourceChannel: 16,
                                                             destType: .aux, destChannel: 5, panLevel: -50)),
                       "B3 63 51 B3 62 22 B3 06 1F B3 26 7F")
    }

    func testSoftKeyMessage() throws {
        XCTAssertEqual(toString(mixerMessages.softKeyMessage(midiChannel: 1, button: 1, state: .PRESS)), "90 30 7F")
        XCTAssertEqual(toString(mixerMessages.softKeyMessage(midiChannel: 1, button: 2, state: .PRESS)), "90 31 7F")
        XCTAssertEqual(toString(mixerMessages.softKeyMessage(midiChannel: 1, button: 3, state: .PRESS)), "90 32 7F")
        XCTAssertEqual(toString(mixerMessages.softKeyMessage(midiChannel: 1, button: 1, state: .RELEASE)), "80 30 00")
        XCTAssertEqual(toString(mixerMessages.softKeyMessage(midiChannel: 1, button: 2, state: .RELEASE)), "80 31 00")
        XCTAssertEqual(toString(mixerMessages.softKeyMessage(midiChannel: 1, button: 3, state: .RELEASE)), "80 32 00")
    }

    func testSceneRecallMessage() throws {
        XCTAssertEqual(toString(mixerMessages.sceneRecallMessage(midiChannel: 1, scene: 1)), "B0 00 00 B0 20 00 C0 00")
        XCTAssertEqual(toString(mixerMessages.sceneRecallMessage(midiChannel: 1, scene: 7)), "B0 00 00 B0 20 00 C0 06")
        XCTAssertEqual(toString(mixerMessages.sceneRecallMessage(midiChannel: 1, scene: 64)), "B0 00 00 B0 20 00 C0 3F")
    }

    private func toString(_ event: MIDIEvent?) -> String {
        return MidiMessagePublisher.toString(event)
    }
}
