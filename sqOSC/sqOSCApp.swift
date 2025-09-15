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
    @NSApplicationDelegateAdaptor(SqOscAppDelegate.self) var appDelegate: SqOscAppDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appDelegate.apiEndpoints.dictionary)
                .environmentObject(appDelegate.activityLog)
                .environmentObject(appDelegate.oscHandler.messageSender())
                .environment(appDelegate.oscHandler.midiManager)
        }
        .windowResizability(.contentSize)
    }
}

class SqOscAppDelegate: NSObject, NSApplicationDelegate, ObservableObject {
    @Published var activityLog = ActivityLog()
    @Published var apiEndpoints = SqMixerEndpoints(preferences: .standard)
    @Published var oscHandler = SqOscManager()

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        #if DEBUG
        if ProcessInfo.isOnPreview() {
            // Stupid workaround - for some reason the UI previews run the
            // sqOSCApp code and this prevents the server from starting
            // in the preview
            return
        }
        #endif
        oscHandler.start { message in
            Task { @MainActor in
                self.activityLog.logMessage(logText: message)
            }
        }
        oscHandler.register(endpoints: apiEndpoints)
    }

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
