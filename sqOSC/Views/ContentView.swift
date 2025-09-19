//
//  ContentView.swift
//  sqOSC
//
//  Created by H Allen Adams on 7/4/24.
//

import MIDIKit
import OSCKitCore
import SwiftData
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var dictionary: SqMixerEndpointDictionary
    enum Tabs: Equatable, Hashable {
        case log
    }

    var body: some View {
        TabView(
            content: {
                ConfigurationView().tabItem { Text("Status") }.tag(1)
                EndpointDictionaryView(dictionary: dictionary).tabItem { Text("Dictionary") }.tag(2)
                BuilderView(dictionary: dictionary).tabItem { Text("OSC Builder") }.tag(3)
            }).frame(minWidth: 600, maxWidth: 600, minHeight: 400, maxHeight: 400)
    }
}

#Preview {
    @Previewable var endpoints = SqMixerEndpoints(preferences: .standard)
    @Previewable var activityLog = ActivityLog()
    ContentView()
        .environmentObject(activityLog)
        .environmentObject(endpoints.dictionary)
        .environmentObject(OscMessageSender(addressSpace: nil))
        .environment(ObservableMIDIManager(clientName: "Test", model: "Test", manufacturer: "Test"))
}
