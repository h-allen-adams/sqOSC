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
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(apiEndpoints.dictionary)
                .environmentObject(activityLog)
                .environmentObject(oscHandler.messageSender())
                .environment(oscHandler.midiManager)
                .onAppear {
                    if ProcessInfo.isOnPreview() {
                        // Stupid workaround - for some reason the UI previews run the
                        // sqOSCApp code and this prevents the server from starting
                        // in the preview
                        return
                    }
                    oscHandler.start()
                    oscHandler.register(endpoints: apiEndpoints)
                }
                .onDisappear {
                    oscHandler.stop()
                }
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

extension ProcessInfo {
    static func isOnPreview() -> Bool {
        return ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }
}
