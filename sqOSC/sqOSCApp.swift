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

var oscServer = OSCServer(port: 9903)
var activityLog = ActivityLog()

@main
struct sqOSCApp: App {
    @NSApplicationDelegateAdaptor(SwOscAppDelegate.self) var appDelegate: SwOscAppDelegate

    private var apiEndpoints = SqMixerEndpoints(preferences: .standard)
    private var oscHandler: SqOscHandler

    @State var midiManager = ObservableMIDIManager(
        clientName: "sqOSC",
        model: "sqOSC",
        manufacturer: "org.adamaschool"
    )

    init() {
        oscHandler = SqOscHandler(activityLog: activityLog)

        do {
            midiManager.preferredAPI = CoreMIDIAPIVersion.legacyCoreMIDI
            try midiManager.start()
            try midiManager.addOutputConnection(to: MIDIOutputConnectionMode.none, tag: "toSQ")
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
                .environment(midiManager)
        }
        .windowResizability(.contentSize)
    }

    private func setupOSCServer() {
        oscServer.setHandler { message, timeTag in
            do {
                try await self.oscHandler.handle(
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

class SwOscAppDelegate: NSObject, NSApplicationDelegate, ObservableObject {
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

    func applicationWillTerminate(_ notification: Notification) {
        oscServer.stop()
        activityLog.logMessage(logText: "OSC Server Stopped")
        print("OSC Server Stopped")
    }
}
