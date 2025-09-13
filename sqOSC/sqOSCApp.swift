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

let activityLog = ActivityLog()

@main
struct sqOSCApp: App {
    @NSApplicationDelegateAdaptor(SwOscAppDelegate.self) var appDelegate: SwOscAppDelegate

    private var apiEndpoints = SqMixerEndpoints(preferences: .standard)
    private var oscHandler: SqOscManager

    init() {
        oscHandler = SqOscManager { message in
            activityLog.logMessage(logText: message)
        }

        oscHandler.start()
        oscHandler.register(endpoints: apiEndpoints)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(apiEndpoints.dictionary)
                .environmentObject(activityLog)
                .environmentObject(oscHandler)
                .environment(oscHandler.midiManager)
        }
        .windowResizability(.contentSize)
    }
}

class SwOscAppDelegate: NSObject, NSApplicationDelegate, ObservableObject {
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

    func applicationWillTerminate(_ notification: Notification) {}
}
