//
//  sqOSCApp.swift
//  sqOSC
//
//  Created by H Allen Adams on 7/4/24.
//

import OSCKit
import SwiftData
import SwiftUI

@main
struct sqOSCApp: App {
    private var activityLog = ActivityLog()
    private var oscServer = OSCServer(port: 9903)
    private var apiEndpoints = SqMixerEndpoints(mixerConfig: SqMixerConfig())
    private var oscHandler: SqOscHandler

    init() {
        self.oscHandler = SqOscHandler(activityLog: activityLog, endpoints: apiEndpoints) { _, _ in }
        setupOSCServer()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(apiEndpoints.dictionary)
                .environmentObject(activityLog)
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

        do {
            try oscServer.start()
        } catch {
            print(error)
        }
    }
}
