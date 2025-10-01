//
//  MidiMessagePublisher.swift
//  sqOSC
//
//  Created by H Allen Adams on 7/6/24.
//

import Foundation
import MIDIKit

typealias MessagePublisher = (_ label: String, _ message: MIDIEvent) async -> Void

/**
 Publish a MIDI Message to the configured MIDI connection, logging the message
 to the Log Publisher along the way.
 */
struct MidiMessagePublisher {
    let logger: LogPublisher
    var midiManager: MIDIManager?

    /**
     Publish a MIDI Message to the configured MIDI connection, logging the message
     to the Log Publisher along the way.
     */
    @MainActor func publish(label: String, message: MIDIEvent) {
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

    /**
     Convert the MIDI event to a hex string for logging
     */
    static func toString(_ event: MIDIEvent?) -> String {
        var bytes: [UInt8] = []
        if let eventBytes = event?.midi1RawBytes() {
            bytes.append(contentsOf: eventBytes)
        }
        return bytes.hex.stringValue(padTo: 2)
    }

    /**
     Publish a message to the configured logger
     */
    func logMessage(label: String, message: String) {
        logger("\(label) -> \(message)")
    }
}
