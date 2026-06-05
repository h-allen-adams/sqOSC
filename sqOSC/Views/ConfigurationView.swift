//
//  ContentView.swift
//  MIDIKit • https://github.com/orchetect/MIDIKit
//  © 2021-2023 Steffan Andrews • Licensed under MIT License
//

import Combine
import MIDIKitIO
import MIDIKitUI
import SwiftUI

/**
 The Configuration/Status View shows the MIDI configuration options and the live
 message status log. Changing the MIDI options will save them to the preference
 store
 */
struct ConfigurationView: View {
    @Preference(\.midiInput) var midiInput
    @Preference(\.midiInputName) var midiInputName
    @Preference(\.midiChannel) var midiChannel
    @Preference(\.mixerModel) var mixerModel
    @Preference(\.faderLaw) var faderLaw

    @Environment(ObservableMIDIManager.self) private var midiManager
    @EnvironmentObject private var activityLog: ActivityLog
    @EnvironmentObject private var oscDictionary: SqMixerEndpointDictionary

    var body: some View {
        VStack {
            // Activity Log Text view
            TextEditor(text: $activityLog.logText)

            // MIDI Option Pickers

            VStack(alignment: .leading) {
                MIDIInputsPicker(
                    title: "MIDI Destination",
                    selectionID: $midiInput,
                    selectionDisplayName: $midiInputName,
                    showIcons: false,
                    hideOwned: true
                )
                .updatingOutputConnection(withTag: "toSQ")
                .environment(midiManager)
                .frame(maxWidth: .infinity, alignment: .leading)
                Picker("MIDI Channel", selection: $midiChannel) {
                    ForEach(Array(1 ... 16), id: \.self) {
                        Text("\($0)")
                    }
                }
                .pickerStyle(.segmented)
                Picker("Mixer Series", selection: $mixerModel) {
                    ForEach(MixerSeries.displayCases, id: \.self.rawValue) {
                        Text("\($0.title)")
                    }
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: .infinity, alignment: .leading)
                Picker("Fader Law", selection: $faderLaw) {
                    ForEach(oscDictionary.mixerConfig.faderLaws(), id: \.self.rawValue) {
                        Text("\(String(describing: $0))")
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .pickerStyle(.segmented)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.all)
            .onChange(of: mixerModel) { _, _ in
                oscDictionary.reset(mixerModel: MixerSeries(rawValue: mixerModel)!,
                                    faderLaw: FaderLevelLaw(rawValue: faderLaw)!)
                faderLaw = oscDictionary.faderLaw!.rawValue
            }
            .onChange(of: faderLaw) { _, _ in
                oscDictionary.reset(mixerModel: MixerSeries(rawValue: mixerModel)!,
                                    faderLaw: FaderLevelLaw(rawValue: faderLaw)!)
            }
            .flexibleButtonSizing()
        }
    }
}

/**
 Prefeence Property wrapper to bind preferences to the UI for display and update
 */
@propertyWrapper
struct Preference<Value>: DynamicProperty {
    @ObservedObject private var preferencesObserver: PublisherObservableObject
    private let keyPath: ReferenceWritableKeyPath<MixerPreferences, Value>
    private let preferences: MixerPreferences

    init(_ keyPath: ReferenceWritableKeyPath<MixerPreferences, Value>,
         preferences: MixerPreferences = .midiStandard)
    {
        self.keyPath = keyPath
        self.preferences = preferences
        let publisher = preferences
            .preferencesChangedSubject
            .filter { changedKeyPath in
                changedKeyPath == keyPath
            }.map { _ in () }
            .eraseToAnyPublisher()
        preferencesObserver = .init(publisher: publisher)
    }

    var wrappedValue: Value {
        get { preferences[keyPath: keyPath] }
        nonmutating set { preferences[keyPath: keyPath] = newValue }
    }

    var projectedValue: Binding<Value> {
        Binding(
            get: { wrappedValue },
            set: { wrappedValue = $0 }
        )
    }
}

final class PublisherObservableObject: ObservableObject {
    var subscriber: AnyCancellable?

    init(publisher: AnyPublisher<Void, Never>) {
        subscriber = publisher.sink(receiveValue: { [weak self] _ in
            self?.objectWillChange.send()
        })
    }
}

#Preview {
    ConfigurationView()
        .environment(ObservableMIDIManager(clientName: "Test", model: "Test", manufacturer: "Test"))
        .environmentObject(SqMixerEndpointDictionary.forConfiguration(.sq, faderLaw: .LinearTaper))
        .environmentObject(ActivityLog())
}
