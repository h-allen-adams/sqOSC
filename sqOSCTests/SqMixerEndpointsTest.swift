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
    private var endpointRegistrar: SqOscEndpointRegistrar?
    private var addressSpace: OSCAddressSpace?
    private var message = ""
    private let flag = DispatchSemaphore(value: 0)

    override func setUpWithError() throws {
        endpointRegistrar = SqOscEndpointRegistrar(dictionary: SqMixerEndpointDictionary(),
                                                   preferences: .midiStandard)
        { _, message in
            self.message = MidiMessagePublisher.toString(message)
            self.flag.signal()
        }
        addressSpace = OSCAddressSpace()
        message = "UNSET"

        endpointRegistrar?.populate(addressSpace: addressSpace!)
    }

    func testRegisterMutes() throws {
        XCTAssertEqual(callEndpoint("/sq/input/1/mute ON"), "B0 63 00 B0 62 00 B0 06 00 B0 26 01")
        XCTAssertEqual(callEndpoint("/sq/input/48/mute ON"), "B0 63 00 B0 62 2F B0 06 00 B0 26 01")
        XCTAssertEqual(callEndpoint("/sq/main/mute ON"), "B0 63 00 B0 62 44 B0 06 00 B0 26 01")
        XCTAssertEqual(callEndpoint("/sq/aux/1/mute ON"), "B0 63 00 B0 62 45 B0 06 00 B0 26 01")
        XCTAssertEqual(callEndpoint("/sq/aux/12/mute ON"), "B0 63 00 B0 62 50 B0 06 00 B0 26 01")
        XCTAssertEqual(callEndpoint("/sq/group/1/mute ON"), "B0 63 00 B0 62 30 B0 06 00 B0 26 01")
        XCTAssertEqual(callEndpoint("/sq/group/12/mute ON"), "B0 63 00 B0 62 3B B0 06 00 B0 26 01")
        XCTAssertEqual(callEndpoint("/sq/fxReturn/1/mute ON"), "B0 63 00 B0 62 3C B0 06 00 B0 26 01")
        XCTAssertEqual(callEndpoint("/sq/fxReturn/8/mute ON"), "B0 63 00 B0 62 43 B0 06 00 B0 26 01")
        XCTAssertEqual(callEndpoint("/sq/fxSend/1/mute ON"), "B0 63 00 B0 62 51 B0 06 00 B0 26 01")
        XCTAssertEqual(callEndpoint("/sq/fxSend/4/mute ON"), "B0 63 00 B0 62 54 B0 06 00 B0 26 01")
        XCTAssertEqual(callEndpoint("/sq/matrix/1/mute ON"), "B0 63 00 B0 62 55 B0 06 00 B0 26 01")
        XCTAssertEqual(callEndpoint("/sq/matrix/3/mute ON"), "B0 63 00 B0 62 57 B0 06 00 B0 26 01")
        XCTAssertEqual(callEndpoint("/sq/dca/1/mute ON"), "B0 63 02 B0 62 00 B0 06 00 B0 26 01")
        XCTAssertEqual(callEndpoint("/sq/dca/8/mute ON"), "B0 63 02 B0 62 07 B0 06 00 B0 26 01")
        XCTAssertEqual(callEndpoint("/sq/muteGroup/1/mute ON"), "B0 63 04 B0 62 00 B0 06 00 B0 26 01")
        XCTAssertEqual(callEndpoint("/sq/muteGroup/8/mute ON"), "B0 63 04 B0 62 07 B0 06 00 B0 26 01")
    }

    func testRegisterOutputLevels() throws {
        XCTAssertEqual(callEndpoint("/sq/main/level 0"), "B0 63 4F B0 62 00 B0 06 76 B0 26 5C")
        XCTAssertEqual(callEndpoint("/sq/aux/1/level 0"), "B0 63 4F B0 62 01 B0 06 76 B0 26 5C")
        XCTAssertEqual(callEndpoint("/sq/aux/12/level 0"), "B0 63 4F B0 62 0C B0 06 76 B0 26 5C")
        XCTAssertEqual(callEndpoint("/sq/fxSend/1/level 0"), "B0 63 4F B0 62 0D B0 06 76 B0 26 5C")
        XCTAssertEqual(callEndpoint("/sq/fxSend/4/level 0"), "B0 63 4F B0 62 10 B0 06 76 B0 26 5C")
        XCTAssertEqual(callEndpoint("/sq/matrix/1/level 0"), "B0 63 4F B0 62 11 B0 06 76 B0 26 5C")
        XCTAssertEqual(callEndpoint("/sq/matrix/3/level 0"), "B0 63 4F B0 62 13 B0 06 76 B0 26 5C")
        XCTAssertEqual(callEndpoint("/sq/dca/1/level 0"), "B0 63 4F B0 62 20 B0 06 76 B0 26 5C")
        XCTAssertEqual(callEndpoint("/sq/dca/8/level 0"), "B0 63 4F B0 62 27 B0 06 76 B0 26 5C")
    }

    func testRegisterSendLevels() throws {
        XCTAssertEqual(callEndpoint("/sq/input/1/to/main/sendLevel 0"),
                       "B0 63 40 B0 62 00 B0 06 76 B0 26 5C")
        XCTAssertEqual(callEndpoint("/sq/input/48/to/main/sendLevel 0"),
                       "B0 63 40 B0 62 2F B0 06 76 B0 26 5C")
        XCTAssertEqual(callEndpoint("/sq/input/1/to/aux/1/sendLevel 0"),
                       "B0 63 40 B0 62 44 B0 06 76 B0 26 5C")
        XCTAssertEqual(callEndpoint("/sq/input/48/to/aux/1/sendLevel 0"),
                       "B0 63 44 B0 62 78 B0 06 76 B0 26 5C")
        XCTAssertEqual(callEndpoint("/sq/input/1/to/aux/12/sendLevel 0"),
                       "B0 63 40 B0 62 4F B0 06 76 B0 26 5C")
        XCTAssertEqual(callEndpoint("/sq/input/48/to/aux/12/sendLevel 0"),
                       "B0 63 45 B0 62 03 B0 06 76 B0 26 5C")
        XCTAssertEqual(callEndpoint("/sq/input/1/to/fxSend/1/sendLevel 0"),
                       "B0 63 4C B0 62 14 B0 06 76 B0 26 5C")
        XCTAssertEqual(callEndpoint("/sq/input/48/to/fxSend/1/sendLevel 0"),
                       "B0 63 4D B0 62 50 B0 06 76 B0 26 5C")
        XCTAssertEqual(callEndpoint("/sq/input/1/to/fxSend/4/sendLevel 0"),
                       "B0 63 4C B0 62 17 B0 06 76 B0 26 5C")
        XCTAssertEqual(callEndpoint("/sq/input/48/to/fxSend/4/sendLevel 0"),
                       "B0 63 4D B0 62 53 B0 06 76 B0 26 5C")
    }

    func testRegisterSendPan() throws {
        XCTAssertEqual(callEndpoint("/sq/input/1/to/main/pan -100"),
                       "B0 63 50 B0 62 00 B0 06 00 B0 26 00")
        XCTAssertEqual(callEndpoint("/sq/input/1/to/main/pan 0"),
                       "B0 63 50 B0 62 00 B0 06 3F B0 26 7F")
        XCTAssertEqual(callEndpoint("/sq/input/24/to/main/pan 20"),
                       "B0 63 50 B0 62 17 B0 06 4C B0 26 65")
        XCTAssertEqual(callEndpoint("/sq/input/24/to/aux/5/pan 20"),
                       "B0 63 52 B0 62 5C B0 06 4C B0 26 65")
    }

    func testRegisterMixAssignment() throws {
        XCTAssertEqual(callEndpoint("/sq/input/1/to/main/assign ON"),
                       "B0 63 60 B0 62 00 B0 06 00 B0 26 01")
        XCTAssertEqual(callEndpoint("/sq/input/1/to/main/assign OFF"),
                       "B0 63 60 B0 62 00 B0 06 00 B0 26 00")
        XCTAssertEqual(callEndpoint("/sq/fxReturn/1/to/aux/7/assign ON"),
                       "B0 63 66 B0 62 1A B0 06 00 B0 26 01")
        XCTAssertEqual(callEndpoint("/sq/group/1/to/aux/3/assign OFF"),
                       "B0 63 65 B0 62 06 B0 06 00 B0 26 00")
    }

    func testRegisterOutputBalance() throws {
        XCTAssertEqual(callEndpoint("/sq/main/balance -100"),
                       "B0 63 5F B0 62 00 B0 06 00 B0 26 00")
    }

    func testRegisterSceneRecall() throws {
        XCTAssertEqual(callEndpoint("/sq/scene/156/recall"), "B0 00 00 B0 20 01 C0 1B")
    }

    func testRegisterSoftKeys() throws {
        XCTAssertEqual(callEndpoint("/sq/softKey/1/trigger PRESS"), "90 30 7F")
        XCTAssertEqual(callEndpoint("/sq/softKey/3/trigger RELEASE"), "80 32 00")
    }

    private func callEndpoint(_ messageString: String) -> String {
        message = "UNSET"
        OscMessageSender(addressSpace: addressSpace).callEndpoint(messageString)
        if flag.wait(timeout: DispatchTime.now() + 3) == .timedOut {
            message = "TIMEOUT"
        }
        return message
    }
}
