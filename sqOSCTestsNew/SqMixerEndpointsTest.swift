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
    private var mixerConfig = SqMixerConfig(numSoftKeys: 3, numInput: 4, numGroup: 2, numMain: 1, numAux: 2, numfxReturn: 4, numfxSend: 2, numMatrix: 3, numDca: 2, numMuteGroup: 2)
    private var mixerEndpoints: SqMixerEndpoints?
    private var addressSpace: OSCAddressSpace?
    private var dictionary: EndpointDictionary?
    private var message = ""

    override func setUpWithError() throws {
        mixerEndpoints = SqMixerEndpoints(mixerConfig: mixerConfig)
        addressSpace = OSCAddressSpace()
        message = "UNSET"

        mixerEndpoints?.register(addressSpace: addressSpace!) { _, message in
            self.message = message
        }
    }

    func testRegisterMutes() throws {
        XCTAssertEqual(callEndpoint("/sq/input/1/mute", OSCValues(arrayLiteral: "ON")), "B0 63 00 B0 62 00 B0 06 00 B0 26 01")
        XCTAssertEqual(callEndpoint("/sq/input/2/mute", OSCValues(arrayLiteral: "ON")), "B0 63 00 B0 62 01 B0 06 00 B0 26 01")
        XCTAssertEqual(callEndpoint("/sq/input/3/mute", OSCValues(arrayLiteral: "ON")), "B0 63 00 B0 62 02 B0 06 00 B0 26 01")
        XCTAssertEqual(callEndpoint("/sq/input/4/mute", OSCValues(arrayLiteral: "ON")), "B0 63 00 B0 62 03 B0 06 00 B0 26 01")
        XCTAssertEqual(callEndpoint("/sq/main/mute", OSCValues(arrayLiteral: "ON")), "B0 63 00 B0 62 44 B0 06 00 B0 26 01")
        XCTAssertEqual(callEndpoint("/sq/aux/1/mute", OSCValues(arrayLiteral: "ON")), "B0 63 00 B0 62 45 B0 06 00 B0 26 01")
        XCTAssertEqual(callEndpoint("/sq/aux/2/mute", OSCValues(arrayLiteral: "ON")), "B0 63 00 B0 62 46 B0 06 00 B0 26 01")
        XCTAssertEqual(callEndpoint("/sq/group/1/mute", OSCValues(arrayLiteral: "ON")), "B0 63 00 B0 62 30 B0 06 00 B0 26 01")
        XCTAssertEqual(callEndpoint("/sq/group/2/mute", OSCValues(arrayLiteral: "ON")), "B0 63 00 B0 62 31 B0 06 00 B0 26 01")
        XCTAssertEqual(callEndpoint("/sq/fxReturn/1/mute", OSCValues(arrayLiteral: "ON")), "B0 63 00 B0 62 3C B0 06 00 B0 26 01")
        XCTAssertEqual(callEndpoint("/sq/fxReturn/2/mute", OSCValues(arrayLiteral: "ON")), "B0 63 00 B0 62 3D B0 06 00 B0 26 01")
        XCTAssertEqual(callEndpoint("/sq/fxReturn/3/mute", OSCValues(arrayLiteral: "ON")), "B0 63 00 B0 62 3E B0 06 00 B0 26 01")
        XCTAssertEqual(callEndpoint("/sq/fxReturn/4/mute", OSCValues(arrayLiteral: "ON")), "B0 63 00 B0 62 3F B0 06 00 B0 26 01")
        XCTAssertEqual(callEndpoint("/sq/fxSend/1/mute", OSCValues(arrayLiteral: "ON")), "B0 63 00 B0 62 51 B0 06 00 B0 26 01")
        XCTAssertEqual(callEndpoint("/sq/fxSend/2/mute", OSCValues(arrayLiteral: "ON")), "B0 63 00 B0 62 52 B0 06 00 B0 26 01")
        XCTAssertEqual(callEndpoint("/sq/matrix/1/mute", OSCValues(arrayLiteral: "ON")), "B0 63 00 B0 62 55 B0 06 00 B0 26 01")
        XCTAssertEqual(callEndpoint("/sq/dca/1/mute", OSCValues(arrayLiteral: "ON")), "B0 63 02 B0 62 00 B0 06 00 B0 26 01")
        XCTAssertEqual(callEndpoint("/sq/dca/2/mute", OSCValues(arrayLiteral: "ON")), "B0 63 02 B0 62 01 B0 06 00 B0 26 01")
        XCTAssertEqual(callEndpoint("/sq/muteGroup/1/mute", OSCValues(arrayLiteral: "ON")), "B0 63 04 B0 62 00 B0 06 00 B0 26 01")
        XCTAssertEqual(callEndpoint("/sq/muteGroup/2/mute", OSCValues(arrayLiteral: "ON")), "B0 63 04 B0 62 01 B0 06 00 B0 26 01")
    }

    func testRegisterOutputLevels() throws {
        XCTAssertEqual(callEndpoint("/sq/main/level", OSCValues(arrayLiteral: 0)), "B0 63 4F B0 62 00 B0 06 76 B0 26 5C")
        XCTAssertEqual(callEndpoint("/sq/aux/1/level", OSCValues(arrayLiteral: 0)), "B0 63 4F B0 62 01 B0 06 76 B0 26 5C")
        XCTAssertEqual(callEndpoint("/sq/aux/2/level", OSCValues(arrayLiteral: 0)), "B0 63 4F B0 62 02 B0 06 76 B0 26 5C")
        XCTAssertEqual(callEndpoint("/sq/fxSend/1/level", OSCValues(arrayLiteral: 0)), "B0 63 4F B0 62 0D B0 06 76 B0 26 5C")
        XCTAssertEqual(callEndpoint("/sq/fxSend/2/level", OSCValues(arrayLiteral: 0)), "B0 63 4F B0 62 0E B0 06 76 B0 26 5C")
        XCTAssertEqual(callEndpoint("/sq/matrix/1/level", OSCValues(arrayLiteral: 0)), "B0 63 4F B0 62 11 B0 06 76 B0 26 5C")
        XCTAssertEqual(callEndpoint("/sq/matrix/2/level", OSCValues(arrayLiteral: 0)), "B0 63 4F B0 62 12 B0 06 76 B0 26 5C")
        XCTAssertEqual(callEndpoint("/sq/matrix/3/level", OSCValues(arrayLiteral: 0)), "B0 63 4F B0 62 13 B0 06 76 B0 26 5C")
        XCTAssertEqual(callEndpoint("/sq/dca/1/level", OSCValues(arrayLiteral: 0)), "B0 63 4F B0 62 20 B0 06 76 B0 26 5C")
        XCTAssertEqual(callEndpoint("/sq/dca/2/level", OSCValues(arrayLiteral: 0)), "B0 63 4F B0 62 21 B0 06 76 B0 26 5C")
    }

    func testRegisterSceneRecall() throws {
        XCTAssertEqual(callEndpoint("/sq/scene/recall", OSCValues(arrayLiteral: 156)), "B0 00 01 C0 1B")
    }

    func testRegisterSoftKeys() throws {
        XCTAssertEqual(callEndpoint("/sq/softKey/1/trigger", OSCValues(arrayLiteral: "PRESS")), "90 30 7F")
        XCTAssertEqual(callEndpoint("/sq/softKey/3/trigger", OSCValues(arrayLiteral: "RELEASE")), "80 32 00")
    }

    private func callEndpoint(_ address: String, _ values: OSCValues) -> String {
        message = "UNSET"
        addressSpace?.dispatch(OSCMessage(OSCAddressPattern(address), values: values))
        return message
    }
}
