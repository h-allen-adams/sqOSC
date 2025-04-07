//
//  MidiMessagePublisher.swift
//  sqOSC
//
//  Created by H Allen Adams on 7/6/24.
//

import Foundation
import MIDIKit

struct MidiMessagePublisher {
    let activityLog: ActivityLog
    var midiManager: MIDIManager?

    @MainActor func publish(label: String, message: MIDIEvent) {
        if let connection = midiManager?.managedOutputConnections["toSQ"] {
            do {
                activityLog.logMessage(logText: "\(label) -> \(Self.toString(message))")
                // try connection.send(event: MIDIEvent.sysEx7(manufacturer: .oneByte(0x7D), data: []))
                try connection.send(event: message)
            } catch {
                activityLog.logMessage(logText: "\(label) -> ERROR \(error)")
            }
        }
    }

    static func toString(_ event: MIDIEvent?) -> String {
        var bytes: [UInt8] = []
        if let eventBytes = event?.midi1RawBytes() {
            bytes.append(contentsOf: eventBytes)
        }
        return bytes.hex.stringValue(padTo: 2)
    }
}
