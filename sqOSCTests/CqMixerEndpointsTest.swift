//
//  SqMixerEndpointsTest.swift
//  sqOSCTests
//
//  Created by H Allen Adams on 7/5/24.
//

import OSCKitCore
@testable import sqOSC
import XCTest

final class CqMixerEndpointsTest: XCTestCase {
    private var endpointRegistrar: SqOscEndpointRegistrar?
    private var addressSpace: OSCAddressSpace?
    private var message = ""
    private let flag = DispatchSemaphore(value: 0)

    override func setUpWithError() throws {
        endpointRegistrar = SqOscEndpointRegistrar(dictionary: SqMixerEndpointDictionary.forConfiguration(.cq),
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
        XCTAssertEqual(callEndpoint("/input/1/mute ON"), "B0 63 00 B0 62 00 B0 06 00 B0 26 01")
        XCTAssertEqual(callEndpoint("/input/st1/mute ON"), "B0 63 00 B0 62 18 B0 06 00 B0 26 01")
        XCTAssertEqual(callEndpoint("/input/st2/mute ON"), "B0 63 00 B0 62 1A B0 06 00 B0 26 01")
        XCTAssertEqual(callEndpoint("/input/usb/mute ON"), "B0 63 00 B0 62 1C B0 06 00 B0 26 01")
        XCTAssertEqual(callEndpoint("/input/bt/mute ON"), "B0 63 00 B0 62 1E B0 06 00 B0 26 01")
        XCTAssertEqual(callEndpoint("/main/mute ON"), "B0 63 00 B0 62 44 B0 06 00 B0 26 01")
        XCTAssertEqual(callEndpoint("/aux/1/mute ON"), "B0 63 00 B0 62 45 B0 06 00 B0 26 01")
        XCTAssertEqual(callEndpoint("/fxReturn/1/mute ON"), "B0 63 00 B0 62 3C B0 06 00 B0 26 01")
        XCTAssertEqual(callEndpoint("/fxReturn/4/mute ON"), "B0 63 00 B0 62 3F B0 06 00 B0 26 01")
        XCTAssertEqual(callEndpoint("/fxSend/1/mute ON"), "B0 63 00 B0 62 51 B0 06 00 B0 26 01")
        XCTAssertEqual(callEndpoint("/fxSend/4/mute ON"), "B0 63 00 B0 62 54 B0 06 00 B0 26 01")
        XCTAssertEqual(callEndpoint("/dca/1/mute ON"), "B0 63 02 B0 62 00 B0 06 00 B0 26 01")
        XCTAssertEqual(callEndpoint("/dca/4/mute ON"), "B0 63 02 B0 62 03 B0 06 00 B0 26 01")
        XCTAssertEqual(callEndpoint("/muteGroup/1/mute ON"), "B0 63 04 B0 62 00 B0 06 00 B0 26 01")
        XCTAssertEqual(callEndpoint("/muteGroup/4/mute ON"), "B0 63 04 B0 62 03 B0 06 00 B0 26 01")
    }

    func testRegisterOutputLevels() throws {
        XCTAssertEqual(callEndpoint("/main/level 0"), "B0 63 4F B0 62 00 B0 06 62 B0 26 00")
        XCTAssertEqual(callEndpoint("/aux/1/level 0"), "B0 63 4F B0 62 01 B0 06 62 B0 26 00")
        XCTAssertEqual(callEndpoint("/aux/6/level 0"), "B0 63 4F B0 62 06 B0 06 62 B0 26 00")
        XCTAssertEqual(callEndpoint("/fxSend/1/level 0"), "B0 63 4F B0 62 0D B0 06 62 B0 26 00")
        XCTAssertEqual(callEndpoint("/fxSend/4/level 0"), "B0 63 4F B0 62 10 B0 06 62 B0 26 00")
        XCTAssertEqual(callEndpoint("/dca/1/level 0"), "B0 63 4F B0 62 20 B0 06 62 B0 26 00")
        XCTAssertEqual(callEndpoint("/dca/4/level 0"), "B0 63 4F B0 62 23 B0 06 62 B0 26 00")
    }

    func testRegisterSendLevels() throws {
        XCTAssertEqual(callEndpoint("/input/1/to/main/sendLevel 0"),
                       "B0 63 40 B0 62 00 B0 06 62 B0 26 00")
        XCTAssertEqual(callEndpoint("/input/16/to/main/sendLevel 0"),
                       "B0 63 40 B0 62 0F B0 06 62 B0 26 00")
        XCTAssertEqual(callEndpoint("/input/st1/to/main/sendLevel 0"),
                       "B0 63 40 B0 62 18 B0 06 62 B0 26 00")
        XCTAssertEqual(callEndpoint("/input/st2/to/main/sendLevel 0"),
                       "B0 63 40 B0 62 1A B0 06 62 B0 26 00")
        XCTAssertEqual(callEndpoint("/input/usb/to/main/sendLevel 0"),
                       "B0 63 40 B0 62 1C B0 06 62 B0 26 00")
        XCTAssertEqual(callEndpoint("/input/bt/to/main/sendLevel 0"),
                       "B0 63 40 B0 62 1E B0 06 62 B0 26 00")
        XCTAssertEqual(callEndpoint("/input/1/to/aux/1/sendLevel 0"),
                       "B0 63 40 B0 62 44 B0 06 62 B0 26 00")
        XCTAssertEqual(callEndpoint("/input/16/to/aux/1/sendLevel 0"),
                       "B0 63 41 B0 62 1E B0 06 62 B0 26 00")
        XCTAssertEqual(callEndpoint("/input/1/to/fxSend/1/sendLevel 0"),
                       "B0 63 4C B0 62 14 B0 06 62 B0 26 00")
        XCTAssertEqual(callEndpoint("/input/1/to/fxSend/4/sendLevel 0"),
                       "B0 63 4C B0 62 17 B0 06 62 B0 26 00")
        XCTAssertEqual(callEndpoint("/input/16/to/fxSend/4/sendLevel 0"),
                       "B0 63 4C B0 62 53 B0 06 62 B0 26 00")
    }

    func testRegisterSendPan() throws {
        XCTAssertEqual(callEndpoint("/input/1/to/main/pan -100"),
                       "B0 63 50 B0 62 00 B0 06 00 B0 26 00")
        XCTAssertEqual(callEndpoint("/input/1/to/main/pan 0"),
                       "B0 63 50 B0 62 00 B0 06 40 B0 26 00")
        XCTAssertEqual(callEndpoint("/input/16/to/main/pan 20"),
                       "B0 63 50 B0 62 0F B0 06 4C B0 26 65")
        XCTAssertEqual(callEndpoint("/input/16/to/aux/5/pan 20"),
                       "B0 63 51 B0 62 22 B0 06 4C B0 26 65")
        XCTAssertEqual(callEndpoint("/input/st1/to/main/pan 0"),
                       "B0 63 50 B0 62 18 B0 06 40 B0 26 00")
        XCTAssertEqual(callEndpoint("/input/st2/to/main/pan 0"),
                       "B0 63 50 B0 62 1A B0 06 40 B0 26 00")
        XCTAssertEqual(callEndpoint("/input/usb/to/main/pan 0"),
                       "B0 63 50 B0 62 1C B0 06 40 B0 26 00")
        XCTAssertEqual(callEndpoint("/input/bt/to/main/pan 0"),
                       "B0 63 50 B0 62 1E B0 06 40 B0 26 00")
    }

    func testRegisterSceneRecall() throws {
        XCTAssertEqual(callEndpoint("/scene/100/recall"), "B0 00 00 B0 20 00 C0 63")
    }

    func testRegisterSoftKeys() throws {
        XCTAssertEqual(callEndpoint("/softKey/1/trigger PRESS"), "90 30 7F")
        XCTAssertEqual(callEndpoint("/softKey/3/trigger RELEASE"), "80 32 00")
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
