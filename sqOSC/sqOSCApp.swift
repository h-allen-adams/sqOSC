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
    private var oscHandler: SqOscHandler

    init() {
        self.oscHandler = SqOscHandler { _, _ in }
    }

    var body: some Scene {
        WindowGroup {
            ContentView(handler: self.oscHandler)
        }
    }
}
