//
//  SqMixerEndpointsTest.swift
//  sqOSCTests
//
//  Created by H Allen Adams on 7/5/24.
//

import OSCKit
@testable import sqOSC
import XCTest

final class SqMixerEndpointsTest: XCTestCase {
    private var mixerConfig = SqMixerConfig(numInput: 4, numGroup: 2, numMain: 1, numAux: 2, numfxReturn: 2, numfxSend: 1, numMatrix: 1, numDca: 2, numMuteGroup: 2)
    private var mixerEndpoints: SqMixerEndpoints?
    private var addressSpace: OSCAddressSpace?
    private var message = ""

    override func setUpWithError() throws {
        mixerEndpoints = SqMixerEndpoints(mixerConfig: mixerConfig)
        addressSpace = OSCAddressSpace()
        message = "UNSET"
    }

    func testRegisterMutes() throws {
        mixerEndpoints?.register(addressSpace: addressSpace!) { _, message in
            self.message = message
        }

        XCTAssertEqual(callEndpoint("/sq/input/1/mute", OSCValues(arrayLiteral: "ON")), "B0 63 00 B0 62 00 B0 06 00 B0 26 01")
        XCTAssertEqual(callEndpoint("/sq/input/2/mute", OSCValues(arrayLiteral: "ON")), "B0 63 00 B0 62 01 B0 06 00 B0 26 01")
        XCTAssertEqual(callEndpoint("/sq/input/3/mute", OSCValues(arrayLiteral: "ON")), "B0 63 00 B0 62 02 B0 06 00 B0 26 01")
        XCTAssertEqual(callEndpoint("/sq/input/4/mute", OSCValues(arrayLiteral: "ON")), "B0 63 00 B0 62 03 B0 06 00 B0 26 01")
    }

    private func callEndpoint(_ address: String, _ values: OSCValues) -> String {
        addressSpace?.dispatch(OSCMessage(OSCAddressPattern(address), values: values))
        return message
    }
}
