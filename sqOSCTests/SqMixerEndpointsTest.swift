//
//  SqMixerEndpointsTest.swift
//  sqOSCTests
//
//  Created by H Allen Adams on 7/5/24.
//

import OSCKitCore
@testable import sqOSC
import XCTest

final class SqMixerEndpointsTest: XCTestCase {
    private var mixerEndpoints: SqMixerEndpoints?
    private var addressSpace: OSCAddressSpace?
    private var message = ""
    private let flag = DispatchSemaphore(value: 0)

    override func setUpWithError() throws {
        mixerEndpoints = SqMixerEndpoints(preferences: .standard)
        addressSpace = OSCAddressSpace()
        message = "UNSET"

        mixerEndpoints?.register(addressSpace: addressSpace!) { _, message in
            self.message = MidiMessagePublisher.toString(message)
            self.flag.signal()
        }
    }

    func testRegisterMutes() throws {
        XCTAssertEqual(callEndpoint("/sq/input/1/mute", OSCValues(arrayLiteral: "ON")), "B0 63 00 B0 62 00 B0 06 00 B0 26 01")
        XCTAssertEqual(callEndpoint("/sq/input/48/mute", OSCValues(arrayLiteral: "ON")), "B0 63 00 B0 62 2F B0 06 00 B0 26 01")
        XCTAssertEqual(callEndpoint("/sq/main/mute", OSCValues(arrayLiteral: "ON")), "B0 63 00 B0 62 44 B0 06 00 B0 26 01")
        XCTAssertEqual(callEndpoint("/sq/aux/1/mute", OSCValues(arrayLiteral: "ON")), "B0 63 00 B0 62 45 B0 06 00 B0 26 01")
        XCTAssertEqual(callEndpoint("/sq/aux/12/mute", OSCValues(arrayLiteral: "ON")), "B0 63 00 B0 62 50 B0 06 00 B0 26 01")
        XCTAssertEqual(callEndpoint("/sq/group/1/mute", OSCValues(arrayLiteral: "ON")), "B0 63 00 B0 62 30 B0 06 00 B0 26 01")
        XCTAssertEqual(callEndpoint("/sq/group/12/mute", OSCValues(arrayLiteral: "ON")), "B0 63 00 B0 62 3B B0 06 00 B0 26 01")
        XCTAssertEqual(callEndpoint("/sq/fxReturn/1/mute", OSCValues(arrayLiteral: "ON")), "B0 63 00 B0 62 3C B0 06 00 B0 26 01")
        XCTAssertEqual(callEndpoint("/sq/fxReturn/8/mute", OSCValues(arrayLiteral: "ON")), "B0 63 00 B0 62 43 B0 06 00 B0 26 01")
        XCTAssertEqual(callEndpoint("/sq/fxSend/1/mute", OSCValues(arrayLiteral: "ON")), "B0 63 00 B0 62 51 B0 06 00 B0 26 01")
        XCTAssertEqual(callEndpoint("/sq/fxSend/4/mute", OSCValues(arrayLiteral: "ON")), "B0 63 00 B0 62 54 B0 06 00 B0 26 01")
        XCTAssertEqual(callEndpoint("/sq/matrix/1/mute", OSCValues(arrayLiteral: "ON")), "B0 63 00 B0 62 55 B0 06 00 B0 26 01")
        XCTAssertEqual(callEndpoint("/sq/matrix/3/mute", OSCValues(arrayLiteral: "ON")), "B0 63 00 B0 62 57 B0 06 00 B0 26 01")
        XCTAssertEqual(callEndpoint("/sq/dca/1/mute", OSCValues(arrayLiteral: "ON")), "B0 63 02 B0 62 00 B0 06 00 B0 26 01")
        XCTAssertEqual(callEndpoint("/sq/dca/8/mute", OSCValues(arrayLiteral: "ON")), "B0 63 02 B0 62 07 B0 06 00 B0 26 01")
        XCTAssertEqual(callEndpoint("/sq/muteGroup/1/mute", OSCValues(arrayLiteral: "ON")), "B0 63 04 B0 62 00 B0 06 00 B0 26 01")
        XCTAssertEqual(callEndpoint("/sq/muteGroup/8/mute", OSCValues(arrayLiteral: "ON")), "B0 63 04 B0 62 07 B0 06 00 B0 26 01")
    }

    func testRegisterOutputLevels() throws {
        XCTAssertEqual(callEndpoint("/sq/main/level", OSCValues(arrayLiteral: 0)), "B0 63 4F B0 62 00 B0 06 76 B0 26 5C")
        XCTAssertEqual(callEndpoint("/sq/aux/1/level", OSCValues(arrayLiteral: 0)), "B0 63 4F B0 62 01 B0 06 76 B0 26 5C")
        XCTAssertEqual(callEndpoint("/sq/aux/12/level", OSCValues(arrayLiteral: 0)), "B0 63 4F B0 62 0C B0 06 76 B0 26 5C")
        XCTAssertEqual(callEndpoint("/sq/fxSend/1/level", OSCValues(arrayLiteral: 0)), "B0 63 4F B0 62 0D B0 06 76 B0 26 5C")
        XCTAssertEqual(callEndpoint("/sq/fxSend/4/level", OSCValues(arrayLiteral: 0)), "B0 63 4F B0 62 10 B0 06 76 B0 26 5C")
        XCTAssertEqual(callEndpoint("/sq/matrix/1/level", OSCValues(arrayLiteral: 0)), "B0 63 4F B0 62 11 B0 06 76 B0 26 5C")
        XCTAssertEqual(callEndpoint("/sq/matrix/3/level", OSCValues(arrayLiteral: 0)), "B0 63 4F B0 62 13 B0 06 76 B0 26 5C")
        XCTAssertEqual(callEndpoint("/sq/dca/1/level", OSCValues(arrayLiteral: 0)), "B0 63 4F B0 62 20 B0 06 76 B0 26 5C")
        XCTAssertEqual(callEndpoint("/sq/dca/8/level", OSCValues(arrayLiteral: 0)), "B0 63 4F B0 62 27 B0 06 76 B0 26 5C")
    }

    func testRegisterSendLevels() throws {
        XCTAssertEqual(callEndpoint("/sq/input/1/sendLevel/main", OSCValues(arrayLiteral: 0)),
                       "B0 63 40 B0 62 00 B0 06 76 B0 26 5C")
        XCTAssertEqual(callEndpoint("/sq/input/48/sendLevel/main", OSCValues(arrayLiteral: 0)),
                       "B0 63 40 B0 62 2F B0 06 76 B0 26 5C")
        XCTAssertEqual(callEndpoint("/sq/input/1/sendLevel/aux/1", OSCValues(arrayLiteral: 0)),
                       "B0 63 40 B0 62 44 B0 06 76 B0 26 5C")
        XCTAssertEqual(callEndpoint("/sq/input/48/sendLevel/aux/1", OSCValues(arrayLiteral: 0)),
                       "B0 63 44 B0 62 78 B0 06 76 B0 26 5C")
        XCTAssertEqual(callEndpoint("/sq/input/1/sendLevel/aux/12", OSCValues(arrayLiteral: 0)),
                       "B0 63 40 B0 62 4F B0 06 76 B0 26 5C")
        XCTAssertEqual(callEndpoint("/sq/input/48/sendLevel/aux/12", OSCValues(arrayLiteral: 0)),
                       "B0 63 45 B0 62 03 B0 06 76 B0 26 5C")
        XCTAssertEqual(callEndpoint("/sq/input/1/sendLevel/fxSend/1", OSCValues(arrayLiteral: 0)),
                       "B0 63 4C B0 62 14 B0 06 76 B0 26 5C")
        XCTAssertEqual(callEndpoint("/sq/input/48/sendLevel/fxSend/1", OSCValues(arrayLiteral: 0)),
                       "B0 63 4D B0 62 50 B0 06 76 B0 26 5C")
        XCTAssertEqual(callEndpoint("/sq/input/1/sendLevel/fxSend/4", OSCValues(arrayLiteral: 0)),
                       "B0 63 4C B0 62 17 B0 06 76 B0 26 5C")
        XCTAssertEqual(callEndpoint("/sq/input/48/sendLevel/fxSend/4", OSCValues(arrayLiteral: 0)),
                       "B0 63 4D B0 62 53 B0 06 76 B0 26 5C")
    }

    func testRegisterSendPan() throws {
        XCTAssertEqual(callEndpoint("/sq/input/1/pan/main", OSCValues(arrayLiteral: -100)),
                       "B0 63 50 B0 62 00 B0 06 00 B0 26 00")
        XCTAssertEqual(callEndpoint("/sq/input/1/pan/main", OSCValues(arrayLiteral: 0)),
                       "B0 63 50 B0 62 00 B0 06 3F B0 26 7F")
        XCTAssertEqual(callEndpoint("/sq/input/24/pan/main", OSCValues(arrayLiteral: 20)),
                       "B0 63 50 B0 62 17 B0 06 4C B0 26 65")
        XCTAssertEqual(callEndpoint("/sq/input/24/pan/aux/5", OSCValues(arrayLiteral: 20)),
                       "B0 63 52 B0 62 5C B0 06 4C B0 26 65")
    }

    func testRegisterSceneRecall() throws {
        // XCTAssertEqual(callEndpoint("/sq/scene/recall", OSCValues(arrayLiteral: 156)), "B0 00 01 C0 1B")
    }

    func testRegisterSoftKeys() throws {
        XCTAssertEqual(callEndpoint("/sq/softKey/1/trigger", OSCValues(arrayLiteral: "PRESS")), "90 30 7F")
        XCTAssertEqual(callEndpoint("/sq/softKey/3/trigger", OSCValues(arrayLiteral: "RELEASE")), "80 32 00")
    }

    private func callEndpoint(_ address: String, _ values: OSCValues) -> String {
        message = "UNSET"
        addressSpace?.dispatch(OSCMessage(OSCAddressPattern(address), values: values))
        if flag.wait(timeout: DispatchTime.now() + 3) == .timedOut {
            message = "TIMEOUT"
        }
        return message
    }
}
