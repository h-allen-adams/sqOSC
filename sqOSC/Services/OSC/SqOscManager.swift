//
//  SqOscHandler.swift
//  sqOSC
//
//  Created by H Allen Adams on 7/4/24.
//

import Foundation
import MIDIKit
import OSCKit

/**
 OSC Service class managing OSC endpoints and converting OSC messages to MIDI
 messages
 */
class SqOscManager: ObservableObject {
    private var logger: LogPublisher = { _ in }
    @Published var addressSpace = OSCAddressSpace()

    private let oscServer = OSCUDPServer(port: 9903)
    private let midiManager: MIDIManager

    init(midiManager: MIDIManager) {
        self.midiManager = midiManager
    }

    /**
     Start the OSC Server and register the message handler
     */
    func start(logger: @escaping LogPublisher) {
        self.logger = logger

        oscServer.setReceiveHandler { message, timeTag, host, port in
            do {
                try self.handle(
                    message: message,
                    timeTag: timeTag,
                    host: host,
                    port: port
                )
            } catch {
                self.logMessage(label: "ERROR", message: "Error while handling OSC Message: \(error)")
            }
        }

        do {
            try oscServer.start()
            logger("OSC Server Started on Port \(oscServer.localPort)")
            print("OSC Server Started on Port \(oscServer.localPort)")
        } catch {
            logger("ERROR Unable to OSC Start Server on Port \(oscServer.localPort): \(error)")
            print(error)
        }
    }

    /**
     Stop the OSC Server
     */
    func stop() {
        oscServer.stop()
        logger("OSC Server Stopped")
        print("OSC Server Stopped")
    }

    /**
     Register OSC messages in the configured address space based on the
     SqMixerEndpoints
     */
    func register(endpoints: SqOscEndpointRegistrar) {
        logMessage(label: "SETUP", message: "INITIALIZING")

        let midiMessagePublisher = MidiMessagePublisher(logger: logger, midiManager: midiManager)
        endpoints.register(addressSpace: addressSpace) { label, midiMessage in
            await midiMessagePublisher.publish(label: label, message: midiMessage)
        }
    }

    /**
     OSC Message handler. Dispatch the OSC Message to the configured address space.
     */
    public func handle(message: OSCMessage, timeTag: OSCTimeTag, host: String, port: UInt16) throws {
        // logMessage(label: "MESSAGE", message: "\(message)")
        // execute closures for matching methods, and returns the matching method IDs
        let methodIDs = addressSpace.dispatch(message: message, host: host, port: port)

        // if no IDs are returned, it means that the OSC message address pattern did not match any
        // that were registered
        if methodIDs.isEmpty {
            logMessage(label: message.addressPattern.stringValue, message: "UNSUPPORTED")
        }
    }

    /**
     Send a message to the logger
     */
    func logMessage(label: String, message: String) {
        logger("\(label) -> \(message)")
    }

    /**
     Create an OscMessageSender
     */
    func messageSender() -> OscMessageSender {
        return OscMessageSender(addressSpace: addressSpace)
    }
}

/**
 Utility class to send OSC Messages
 */
class OscMessageSender: ObservableObject {
    var addressSpace: OSCAddressSpace?

    init(addressSpace: OSCAddressSpace? = nil) {
        self.addressSpace = addressSpace
    }

    /**
     Dispatch the message to the configured address space as an OSC Message
     */
    func callEndpoint(_ messageString: String) {
        print("callEndpoint: \(messageString)")

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
        let methodIDs = addressSpace!.dispatch(message: oscMessage, host: "localhost", port: 0)
        if methodIDs.isEmpty {
            print("\(oscMessage.addressPattern.stringValue): UNSUPPORTED")
        }
    }
}
