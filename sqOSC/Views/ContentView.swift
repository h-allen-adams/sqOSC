//
//  ContentView.swift
//  sqOSC
//
//  Created by H Allen Adams on 7/4/24.
//

import MIDIKit
import SwiftData
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var dictionary: SqMixerEndpointDictionary
    enum Tabs: Equatable, Hashable {
        case log
    }

    var body: some View {
        TabView(selection: /*@START_MENU_TOKEN@*/ .constant(1)/*@END_MENU_TOKEN@*/,
                content: {
                    ConfigurationView().tabItem { Text("Status") }.tag(1)
                    EndpointDictionaryView(dictionary: dictionary).tabItem { Text("Dictionary") }.tag(2)
                })
    }
}

#Preview {
    ContentView()
        .environmentObject(ActivityLog())
        .environmentObject(SqMixerEndpointDictionary())
        .environmentObject(ObservableMIDIManager(clientName: "Test", model: "Test", manufacturer: "Test"))
}
