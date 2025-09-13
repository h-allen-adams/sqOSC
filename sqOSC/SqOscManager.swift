//
//  SqOscHandler.swift
//  sqOSC
//
//  Created by H Allen Adams on 7/4/24.
//

import Foundation
import MIDIKit
import OSCKit

class SqOscManager: ObservableObject {
    private let logger: LogPublisher
    @Published var addressSpace = OSCAddressSpace()

    private let oscServer = OSCServer(port: 9903)

    @Published var midiManager = ObservableMIDIManager(
        clientName: "sqOSC",
        model: "sqOSC",
        manufacturer: "org.adamaschool"
    )

    init(logger: @escaping LogPublisher) {
        self.logger = logger
    }

    func start() {
        do {
            midiManager.preferredAPI = CoreMIDIAPIVersion.legacyCoreMIDI
            try midiManager.start()
            try midiManager.addOutputConnection(to: MIDIOutputConnectionMode.none, tag: "toSQ")
        } catch {
            logMessage(label: "ERROR", message: "Error while starting MIDI manager: \(error)")
        }

        oscServer.setHandler { message, timeTag in
            do {
                try self.handle(
                    message: message,
                    timeTag: timeTag
                )
            } catch {
                self.logMessage(label: "ERROR", message: "Error while handling OSC Message: \(error)")
            }
        }

        do {
            oscServer.isPortReuseEnabled = true
            try oscServer.start()
            logger("OSC Server Started on Port \(oscServer.localPort)")
        } catch {
            logger("ERROR Unable to OSC Start Server on Port \(oscServer.localPort): \(error)")
            print(error)
        }
    }

    func stop() {
        oscServer.stop()
        logger("OSC Server Stopped")
        print("OSC Server Stopped")
    }

    func register(endpoints: SqMixerEndpoints) {
        logMessage(label: "SETUP", message: "INITIALIZING")

        let midiMessagePublisher = MidiMessagePublisher(logger: logger, midiManager: midiManager)
        endpoints.register(addressSpace: addressSpace) { label, midiMessage in
            midiMessagePublisher.publish(label: label, message: midiMessage)
        }
    }

    public func handle(message: OSCMessage, timeTag: OSCTimeTag) throws {
        // logMessage(label: "MESSAGE", message: "\(message)")
        // execute closures for matching methods, and returns the matching method IDs
        let methodIDs = addressSpace.dispatch(message)

        // if no IDs are returned, it means that the OSC message address pattern did not match any
        // that were registered
        if methodIDs.isEmpty {
            logMessage(label: message.addressPattern.stringValue, message: "UNSUPPORTED")
        }
    }

    func logMessage(label: String, message: String) {
        logger("\(label) -> \(message)")
    }
}

extension OSCAddressSpace {
    func callEndpoint(_ messageString: String) {
        let parts = messageString.split(separator: " ")
        let address = String(parts[0])

        var oscValues = OSCValues()

        for index in 1 ... parts.count - 1 {
            let value = String(parts[index])
            let intValue: Int? = Int(value)
            if intValue != nil {
                oscValues.append(intValue!)
            } else {
                oscValues.append(value)
            }
        }

        let oscMessage = OSCMessage(OSCAddressPattern(address),
                                    values: oscValues)
        dispatch(oscMessage)
    }
}
