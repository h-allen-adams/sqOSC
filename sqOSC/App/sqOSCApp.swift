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

/**
 Main Application
 */
@main
struct sqOSCApp: App {
    @NSApplicationDelegateAdaptor(SqOscAppDelegate.self) var appDelegate: SqOscAppDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appDelegate.midiManager)
                .environmentObject(appDelegate.activityLog)
                .environmentObject(appDelegate.oscDictionary)
                .environmentObject(appDelegate.oscMessageSender)
        }
        .windowResizability(.contentSize)
    }
}

/**
 The App Delegate manages the application services and shared view models.
 */
class SqOscAppDelegate: NSObject, NSApplicationDelegate, ObservableObject {
    public let activityLog = ActivityLog()
    public let apiEndpoints: SqMixerEndpoints
    public let oscDictionary = SqMixerEndpointDictionary()
    public let oscHandler: SqOscManager
    public let oscMessageSender: OscMessageSender
    public let midiManager = ObservableMIDIManager(
        clientName: "sqOSC",
        model: "sqOSC",
        manufacturer: "org.adamaschool"
    )

    override init() {
        self.apiEndpoints = SqMixerEndpoints(dictionary: oscDictionary, preferences: .midiStandard)
        self.oscHandler = SqOscManager(midiManager: midiManager)
        self.oscMessageSender = oscHandler.messageSender()
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

    /**
     Start MIDI and OSC services on application startup
     */
    func applicationWillFinishLaunching(_ notification: Notification) {
        #if DEBUG
        if ProcessInfo.isOnPreview() {
            // Stupid workaround - for some reason the UI previews run the
            // sqOSCApp code and this prevents the server from starting
            // in the preview
            return
        }
        #endif // DEBUG

        do {
            midiManager.preferredAPI = CoreMIDIAPIVersion.legacyCoreMIDI
            try midiManager.start()
            try midiManager.addOutputConnection(to: MIDIOutputConnectionMode.none, tag: "toSQ")
            activityLog.logMessage(logText: "MIDI Manager Started")
        } catch {
            activityLog.logMessage(logText: "ERROR -> Error while starting MIDI manager: \(error)")
        }

        oscHandler.start { message in
            Task { @MainActor in
                self.activityLog.logMessage(logText: message)
            }
        }
        oscHandler.register(endpoints: apiEndpoints)
    }

    /**
     Shutdown OSC service (MIDI services do not need to be explicitly stopped)
     */
    func applicationWillTerminate(_ notification: Notification) {
        print("Will Terminate")
        oscHandler.stop()
    }
}

extension ProcessInfo {
    static func isOnPreview() -> Bool {
        return ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }
}
