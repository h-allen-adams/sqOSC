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
 OSC Service class managing an OSC Server and the associated Address Space OSC
 endpoints. Incoming OSC Messages are dispatched to the Address Space to be
 processed by individual handler methods which generate and publish the matching
 MIDI Message.
 */
class SqOscManager: ObservableObject {
    private let addressSpace = OSCAddressSpace()
    private let logger: LogPublisher
    private let oscServer = OSCUDPServer(port: 9903)

    init(logger: @escaping LogPublisher) {
        self.logger = logger
    }

    /**
     Start the OSC Server and register the message handler
     */
    func start() {
        oscServer.setReceiveHandler(dispatchOscMessage)

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
     Populate the OSC Address Space using the given registrar
     */
    func populateOscAddressSpace(with: SqOscEndpointRegistrar) {
        logger("Initializing OSC Address Space")
        with.populate(addressSpace: addressSpace)
    }

    /**
     OSC Message handler. Dispatch the OSC Message to the configured Address
     Space.
     */
    @Sendable public func dispatchOscMessage(message: OSCMessage,
                                             timeTag: OSCTimeTag,
                                             host: String,
                                             port: UInt16)
    {
        // logMessage(label: "MESSAGE", message: "\(message)")
        // execute closures for matching methods, and returns the matching
        // method IDs
        let methodIDs = addressSpace.dispatch(message: message,
                                              host: host,
                                              port: port)

        // if no IDs are returned, it means that the OSC message address pattern
        // did not match any that were registered
        if methodIDs.isEmpty {
            logMessage(label: message.addressPattern.stringValue,
                       message: "UNSUPPORTED")
        }
    }

    /**
     Send a message to the logger
     */
    func logMessage(label: String, message: String) {
        logger("\(label) -> \(message)")
    }

    func messageSender() -> OscMessageSender {
        OscMessageSender(addressSpace: addressSpace)
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
        let parts = messageString.split(separator: " ")
        let address = String(parts[0])

        var oscValues = OSCValues()

        if parts.count > 1 {
            for index in 1 ... parts.count - 1 {
                let value = String(parts[index])
                let intValue: Int? = Int(value)
                if intValue != nil {
                    oscValues.append(intValue!)
                } else {
                    oscValues.append(value)
                }
            }
        }

        let oscMessage = OSCMessage(OSCAddressPattern(address),
                                    values: oscValues)
        let methodIDs = addressSpace!.dispatch(message: oscMessage,
                                               host: "localhost", port: 0)
        if methodIDs.isEmpty {
            print("\(oscMessage.addressPattern.stringValue): UNSUPPORTED")
        }
    }
}
