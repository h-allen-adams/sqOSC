//
//  Preferences.swift
//  sqOSC
//
//  Created by H Allen Adams on 7/7/24.
//

import Combine
import Foundation
import MIDIKitIO

/**
 Store and access MIDI settings in UserDefaults
 */
final class MixerPreferences {
    static let midiStandard = MixerPreferences(userDefaults: .standard)
    fileprivate let userDefaults: UserDefaults

    init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
    }

    /// Sends through the changed key path whenever a change occurs.
    var preferencesChangedSubject = PassthroughSubject<AnyKeyPath, Never>()

    @UserDefault(PrefKeys.midiInID, defaultValue: nil)
    var midiInput: MIDIIdentifier?

    @UserDefault(PrefKeys.midiInName, defaultValue: nil)
    var midiInputName: String?

    @UserDefault(PrefKeys.midiChannel, defaultValue: 1)
    var midiChannel: Int

    @UserDefault(PrefKeys.mixerModel, defaultValue: "sq")
    var mixerModel: String

    @UserDefault(PrefKeys.faderLaw, defaultValue: "AudioTaper")
    var faderLaw: String

    enum PrefKeys {
        static let midiChannel = "midiChannel"

        static let midiInID = "midiInput"
        static let midiInName = "midiInputName"

        static let midiOutID = "midiOutput"
        static let midiOutName = "midiOutputName"

        static let mixerModel = "mixerModel"

        static let faderLaw = "faderLaw"
    }
}

@propertyWrapper
struct UserDefault<Value> {
    let key: String
    let defaultValue: Value

    var wrappedValue: Value {
        get { fatalError("Wrapped value should not be used.") }
        set { fatalError("Wrapped value should not be used.") }
    }

    init(_ key: String, defaultValue: Value) {
        self.defaultValue = defaultValue
        self.key = key
    }

    public static subscript(
        _enclosingInstance instance: MixerPreferences,
        wrapped wrappedKeyPath: ReferenceWritableKeyPath<MixerPreferences, Value>,
        storage storageKeyPath: ReferenceWritableKeyPath<MixerPreferences, Self>
    ) -> Value {
        get {
            let container = instance.userDefaults
            let key = instance[keyPath: storageKeyPath].key
            let defaultValue = instance[keyPath: storageKeyPath].defaultValue
            return container.object(forKey: key) as? Value ?? defaultValue
        }
        set {
            let container = instance.userDefaults
            let key = instance[keyPath: storageKeyPath].key
            container.set(newValue, forKey: key)
            instance.preferencesChangedSubject.send(wrappedKeyPath)
        }
    }
}
