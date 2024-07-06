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

    func publish(label: String, message: MIDIEvent) {
        if let connection = midiManager?.managedOutputConnections["toSQ"] {
            do {
                try connection.send(event: message)
                activityLog.logMessage(logText: "\(label) -> \(Self.toString(message))")
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
