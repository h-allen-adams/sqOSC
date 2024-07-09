//
//  ContentView.swift
//  MIDIKit • https://github.com/orchetect/MIDIKit
//  © 2021-2023 Steffan Andrews • Licensed under MIT License
//

import Combine
import MIDIKitIO
import MIDIKitUI
import SwiftUI

struct ConfigurationView: View {
    @Preference(\.midiInput) var midiInput
    @Preference(\.midiInputName) var midiInputName
    @Preference(\.midiChannel) var midiChannel

    @EnvironmentObject private var midiManager: ObservableMIDIManager
    @EnvironmentObject private var activityLog: ActivityLog

    var body: some View {
        VStack {
            TextEditor(text: $activityLog.logText)
            MIDIInputsPicker(
                title: "MIDI Destination",
                selectionID: $midiInput,
                selectionDisplayName: $midiInputName,
                showIcons: false,
                hideOwned: true
            )
            .updatingOutputConnection(withTag: "toSQ")
            Picker("MIDI Channel", selection: $midiChannel) {
                ForEach(midiChannels, id: \.self) {
                    Text("\($0)")
                }
            }
            .pickerStyle(.segmented)
        }
    }

    var midiChannels: [Int] = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16]
}

@propertyWrapper
struct Preference<Value>: DynamicProperty {
    @ObservedObject private var preferencesObserver: PublisherObservableObject
    private let keyPath: ReferenceWritableKeyPath<Preferences, Value>
    private let preferences: Preferences

    init(_ keyPath: ReferenceWritableKeyPath<Preferences, Value>, preferences: Preferences = .standard) {
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
        .environmentObject(ObservableMIDIManager(clientName: "Test", model: "Test", manufacturer: "Test"))
        .environmentObject(SqMixerEndpointDictionary())
        .environmentObject(ActivityLog())
}
