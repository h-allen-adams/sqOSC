//
//  sqOSCApp.swift
//  sqOSC
//
//  Created by H Allen Adams on 7/4/24.
//

import MIDIKit
import OSCKit
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
    public let activityLog: ActivityLog
    public let addressSpace = OSCAddressSpace()
    public let logger: LogPublisher
    public let oscDictionary = SqMixerEndpointDictionary(MixerPreferences.midiStandard.mixerModel)
    public let oscManager: SqOscManager
    public let oscMessageSender: OscMessageSender
    public let midiManager = ObservableMIDIManager(
        clientName: "sqOSC",
        model: "sqOSC",
        manufacturer: "org.adamaschool"
    )

    override init() {
        let activityLog = ActivityLog()
        let logger: LogPublisher = { message in
            Task { @MainActor in
                activityLog.logMessage(logText: message)
            }
        }

        self.activityLog = activityLog
        self.logger = logger
        self.oscManager = SqOscManager(addressSpace: addressSpace, logger: logger)
        self.oscMessageSender = oscManager.messageSender()
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

        initializeMidiManager()
        initializeOscHandler()
    }

    /**
     Start the MIDI Manager and add a placeholder "toSQ" output connection. That
     placeholder connection will be updated by the ConfigurationView when the
     MIDI Connection Picker is initialized or changed.
     */
    func initializeMidiManager() {
        do {
            midiManager.preferredAPI = CoreMIDIAPIVersion.legacyCoreMIDI
            try midiManager.start()
            try midiManager.addOutputConnection(to: MIDIOutputConnectionMode.none, tag: "toSQ")
            logger("MIDI Manager Started")
        } catch {
            logger("ERROR: Error while starting MIDI manager: \(error)")
        }
    }

    /**
     Start the OSC Manager and populate the OSC Address Space using the address
     templates from the Mixer Dictionary.
     */
    func initializeOscHandler() {
        let midiMessagePublisher = MidiMessagePublisher(logger: logger,
                                                        midiManager: midiManager)
        let endpointRegistrar = SqOscEndpointRegistrar(dictionary: oscDictionary,
                                                       preferences: .midiStandard)
        { label, midiMessage in
            await midiMessagePublisher.publish(label: label, message: midiMessage)
        }

        oscManager.start()
        logger("Initializing OSC Address Space: \(oscDictionary.mixerConfig.model)")
        endpointRegistrar.populate(addressSpace: addressSpace)
    }

    /**
     Shutdown OSC service (MIDI services do not need to be explicitly stopped)
     */
    func applicationWillTerminate(_ notification: Notification) {
        logger("SHUTDOWN")
        oscManager.stop()
    }
}

extension ProcessInfo {
    static func isOnPreview() -> Bool {
        return ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }
}
