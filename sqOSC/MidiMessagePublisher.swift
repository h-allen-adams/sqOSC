//
//  MidiMessagePublisher.swift
//  sqOSC
//
//  Created by H Allen Adams on 7/6/24.
//

import Foundation
import MIDIKit

struct MidiMessagePublisher {
    let logger: LogPublisher
    var midiManager: MIDIManager?

    func publish(label: String, message: MIDIEvent) {
        if let connection = midiManager?.managedOutputConnections["toSQ"] {
            do {
                logMessage(label: label, message: Self.toString(message))
                try connection.send(event: message)
            } catch {
                logMessage(label: label, message: "ERROR \(error)")
            }
        } else {
            logMessage(label: label, message: "ERROR: No Connection")
        }
    }

    static func toString(_ event: MIDIEvent?) -> String {
        var bytes: [UInt8] = []
        if let eventBytes = event?.midi1RawBytes() {
            bytes.append(contentsOf: eventBytes)
        }
        return bytes.hex.stringValue(padTo: 2)
    }

    func logMessage(label: String, message: String) {
        logger("\(label) -> \(message)")
    }
}
