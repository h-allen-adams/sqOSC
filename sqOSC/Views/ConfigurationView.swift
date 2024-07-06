//
//  ContentView.swift
//  MIDIKit • https://github.com/orchetect/MIDIKit
//  © 2021-2023 Steffan Andrews • Licensed under MIT License
//

import MIDIKitIO
import MIDIKitUI
import SwiftUI

struct ConfigurationView: View {
    @State private var midiInput: MIDIIdentifier?
    @AppStorage(MIDIHelper.PrefKeys.midiInName) private var midiInputName: String?
    @State private var midiOutput: MIDIIdentifier?
    @AppStorage(MIDIHelper.PrefKeys.midiOutName) private var midiOutputName: String?

    @EnvironmentObject private var midiManager: ObservableMIDIManager
    @EnvironmentObject private var midiHelper: MIDIHelper

    var body: some View {
        VStack {
            MIDIInputsPicker(
                title: "MIDI Destination",
                selectionID: $midiInput,
                selectionDisplayName: $midiInputName,
                showIcons: false,
                hideOwned: true
            )
            .updatingOutputConnection(withTag: "toSQ")
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(ObservableMIDIManager(clientName: "Test", model: "Test", manufacturer: "Test"))
        .environmentObject(MIDIHelper())
        .environmentObject(SqMixerEndpointDictionary())
        .environmentObject(ActivityLog())
}
