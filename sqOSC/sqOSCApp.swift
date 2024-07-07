//
//  sqOSCApp.swift
//  sqOSC
//
//  Created by H Allen Adams on 7/4/24.
//

import MIDIKit
import OSCKit
import SwiftData
import SwiftUI

@main
struct sqOSCApp: App {
    private var activityLog = ActivityLog()
    private var oscServer = OSCServer(port: 9903)
    private var apiEndpoints = SqMixerEndpoints(mixerConfig: SqMixerConfig())
    private var oscHandler: SqOscHandler

    @ObservedObject var midiManager = ObservableMIDIManager(
        clientName: "sqOSC",
        model: "sqOSC",
        manufacturer: "org.adamaschool"
    )

    init() {
        oscHandler = SqOscHandler(activityLog: activityLog)

        do {
            try midiManager.start()
            try midiManager.addOutputConnection(to: .none, tag: "toSQ")
        } catch {
            print("Error while starting MIDI manager: \(error)")
        }

        setupOSCServer()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(apiEndpoints.dictionary)
                .environmentObject(activityLog)
                .environmentObject(midiManager)
        }
    }

    private func setupOSCServer() {
        oscServer.setHandler { message, timeTag in
            do {
                try self.oscHandler.handle(
                    message: message,
                    timeTag: timeTag
                )
            } catch {
                print(error)
            }
        }
        let midiMessagePublisher = MidiMessagePublisher(activityLog: activityLog, midiManager: midiManager)
        oscHandler.register(endpoints: apiEndpoints) {
            midiMessagePublisher.publish(label: $0, message: $1)
        }

        do {
            oscServer.isPortReuseEnabled = true
            try oscServer.start()
            activityLog.logMessage(logText: "OSC Server Started on Port \(oscServer.localPort)")
        } catch {
            activityLog.logMessage(logText: "ERROR Unable to OSC Start Server on Port \(oscServer.localPort): \(error)")
            print(error)
        }
    }
}
