//
//  SqOscHandler.swift
//  sqOSC
//
//  Created by H Allen Adams on 7/4/24.
//

import Foundation
import OSCKit

class SqOscHandler: ObservableObject {
    private let activityLog: ActivityLog
    @Published var addressSpace = OSCAddressSpace()

    init(activityLog: ActivityLog) {
        self.activityLog = activityLog
    }

    func register(endpoints: SqMixerEndpoints, publisher: @escaping MessagePublisher) {
        logMessage(label: "SETUP", message: "INITIALIZING")
        endpoints.register(addressSpace: addressSpace, publisher: publisher)
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
        activityLog.logMessage(logText: "\(label) -> \(message)")
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
