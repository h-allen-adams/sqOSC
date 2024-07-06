//
//  SqOscHandler.swift
//  sqOSC
//
//  Created by H Allen Adams on 7/4/24.
//

import Foundation
import OSCKit

class SqOscHandler: ObservableObject {
    @Published var logText = ""
    @Published var dictionary = EndpointDictionary()

    private let addressSpace = OSCAddressSpace()
    private let messagePublisher: MessagePublisher
    private let endpoints: SqMixerEndpoints

    init(messagePublisher: @escaping MessagePublisher) {
        self.messagePublisher = messagePublisher
        self.endpoints = SqMixerEndpoints(mixerConfig: SqMixerConfig())
        logMessage(label: "SETUP", message: "INITIALIZING")
        endpoints.register(addressSpace: addressSpace, dictionary: dictionary) { label, message in
            self.publishMessage(label: label, message: message)
        }
    }

    public func handle(message: OSCMessage, timeTag: OSCTimeTag) throws {
        // execute closures for matching methods, and returns the matching method IDs
        let methodIDs = addressSpace.dispatch(message)

        // if no IDs are returned, it means that the OSC message address pattern did not match any
        // that were registered
        if methodIDs.isEmpty {
            logMessage(label: message.addressPattern.stringValue, message: "UNSUPPORTED")
        }
    }

    func logMessage(label: String, message: String) {
        logText.append("\(label) -> \(message)\n")
    }

    func publishMessage(label: String, message: String) {
        logMessage(label: label, message: message)
        messagePublisher(label, message)
    }
}
