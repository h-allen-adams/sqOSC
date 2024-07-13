//
//  TempTest.swift
//  sqOSCTestsNew
//
//  Created by H Allen Adams on 7/6/24.
//

import MIDIKit
@testable import sqOSC
import XCTest

final class TempTest: XCTestCase {
    private var mixerMessages = SqMixerMessages()

    let midiManager = ObservableMIDIManager(
        clientName: "sqOSC",
        model: "sqOSC",
        manufacturer: "org.adamaschool"
    )

    override func setUpWithError() throws {
        do {
            try midiManager.start()
            try midiManager.addOutputConnection(to: .none, tag: "toSQ")
        } catch {
            print("Error while starting MIDI manager: \(error)")
        }
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        if let connection = midiManager.managedOutputConnections["toSQ"] {
            for endpoint in midiManager.endpoints.inputs {
                if endpoint.name == "MIDI Monitor (Untitled)" {
                    connection.removeAllInputs()
                    connection.add(inputs: [endpoint.asIdentity()])
                }
            }
            try connection.send(event: MIDIEvent.sysEx7(manufacturer: .oneByte(0x7D), data: []))
            try connection.send(event: MIDIEvent.noteOn(60, velocity: .midi1(64), channel: 0))
            try connection.send(event: mixerMessages.softKeyMessage(midiChannel: 1, button: 1, state: SqButtonState.PRESS)!)
            try connection.send(event: mixerMessages.sendLevelMessage(midiChannel: 1, sourceType: EndpointType.input, sourceChannel: 1,
                                                                      destType: EndpointType.main, destChannel: 1, dbLevel: 0)!)
            try connection.send(event: mixerMessages.muteMessage(midiChannel: 1, type: EndpointType.input, channel: 1, action: SqMuteAction.ON)!)
        }
    }
}
