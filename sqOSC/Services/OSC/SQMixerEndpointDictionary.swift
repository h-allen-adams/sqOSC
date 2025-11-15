//
//  EndpointDictionary.swift
//  sqOSC
//
//  Created by H Allen Adams on 7/5/24.
//

import Foundation

/**
 Define the OSC Address Space for the mixer based on the data in the
 SqMixerConfig singleton.

 Every OSC server has a set of OSC Methods. OSC Methods are the potential
 destinations of OSC messages received by the OSC server and correspond to each
 of the points of control that the application makes available. “Invoking” an
 OSC method is analogous to a procedure call; it means supplying the method with
 arguments and causing the method’s effect to take place.

 An OSC Server’s OSC Methods are arranged in a tree strcuture called an OSC
 Address Space. The leaves of this tree are the OSC Methods and the branch nodes
 are called OSC Containers. The mixer OSC Methods correspond to the MIDI
 commands supported by the mixer, defined in MixerMethod. The OSC Containers
 correspond to the mixer channels supported by the MIDI interface.

 The OSC Containers defined by this class are templates: rather than
 fully-defined OSC Addresses, this class produces address templates with
 variable substitution parameters which will be filled in by the
 SqOscEndpointRegistrar.

 For example: "/input/{chNum}/mute" is an OSC Address template which will be
 used to define all the possible mute addresses corresponding to mixer input
 channels: "/input/1/mute", "/input/2/mute", etc.
 */
class SqMixerEndpointDictionary: ObservableObject, Equatable {
    /**
     Currently loaded Mixer Configuration
     */
    @Published var mixerConfig: MixerConfig

    /**
     Dictionary entries for each operation
     */
    @Published var entries: [MixerMethod: EndpointDictEntry]

    /**
     Sorted list of dictionary entries
     */
    @Published var values: [EndpointDictEntry]

    /**
     MIDI Message Factory
     */
    @Published var mixerMessages: MixerMidiMessageFactory?

    /**
     Change handler function called whenever the dictionary is reset.
     */
    private var onChangeHandler: ((_: SqMixerEndpointDictionary) -> Void)?

    init() {
        mixerConfig = MixerConfig.NONE
        entries = [:]
        values = []
        mixerMessages = nil
    }

    /**
     Reset the dictionary by loading the specified mixer configuration
     */
    func reset(_ model: MixerSeries) {
        let mixerConfig = MixerConfig.load(model)
        self.mixerConfig = mixerConfig
        mixerMessages = MixerMidiMessageFactory(mixerConfig: mixerConfig,
                                                faderLaw: mixerConfig.faderLaws().first!)

        entries = mixerConfig.methods().reduce(into: [:]) {
            $0[$1] = EndpointDictEntry(mixerConfig: mixerConfig, operation: $1)
        }

        values = []
        let sorted = entries.sorted { $0.key < $1.key }
        for entry in sorted {
            values.append(entry.value)
        }

        onChangeHandler?(self)
    }

    /**
     Set the change handler function
     */
    func onChange(_ handler: @escaping (_: SqMixerEndpointDictionary) -> Void) {
        onChangeHandler = handler
    }

    /**
     Resolve an OSC Address for the given method and endpoint, substituting
     the values in the template values dictionary into the address template.
     */
    func resolveOscAddress(method: MixerMethod,
                           endpoint: MixerEndpoint,
                           templateValues: [String: String] = [:]) -> String?
    {
        return entries[method]?.resolveOscAddress(endpoint: endpoint,
                                                  templateValues: templateValues)
    }

    /**
     Instantiate a dictionary instance for the given mixer model
     */
    static func forConfiguration(_ model: MixerSeries) -> SqMixerEndpointDictionary {
        let result = SqMixerEndpointDictionary()
        result.reset(model)
        return result
    }

    static func == (lhs: SqMixerEndpointDictionary, rhs: SqMixerEndpointDictionary) -> Bool {
        return lhs.mixerConfig == rhs.mixerConfig
    }
}

/**
 OSC Address Termplate Dictionary entry for a single operation type.
 */
struct EndpointDictEntry: Hashable, Identifiable {
    let id = UUID()
    let operation: MixerMethod
    let addressTemplates: [MixerEndpoint: String]

    init(mixerConfig: MixerConfig, operation: MixerMethod) {
        self.operation = operation
        addressTemplates = Self.addressTemplatesFor(mixerConfig: mixerConfig,
                                                    method: operation)
    }

    /**
     Resolve an OSC Address for the given endpoint substituting the values in
     the template values dictionary into the address template.
     */
    func resolveOscAddress(endpoint: MixerEndpoint,
                           templateValues: [String: String]) -> String?
    {
        guard let path = addressTemplates[endpoint] else { return nil }
        var resolvedPath = path
        for (key, value) in templateValues {
            resolvedPath = resolvedPath.replacingOccurrences(of: "{\(key)}", with: value)
        }
        return resolvedPath
    }

    /**
     OSC Address templates for each endpoint.
     */
    static let oscAddressTemplates = [
        MixerEndpoint.aux: "aux/{chNum}",
        MixerEndpoint.dca: "dca/{chNum}",
        MixerEndpoint.fxReturn: "fxReturn/{chNum}",
        MixerEndpoint.fxSend: "fxSend/{chNum}",
        MixerEndpoint.group: "group/{chNum}",
        MixerEndpoint.input: "input/{chNum}",
        MixerEndpoint.st: "input/st{chNum}",
        MixerEndpoint.usb: "input/usb",
        MixerEndpoint.bt: "input/bt",
        MixerEndpoint.keys: "softKey/{keyNum}",
        MixerEndpoint.main: "main",
        MixerEndpoint.matrix: "matrix/{chNum}",
        MixerEndpoint.muteGroup: "muteGroup/{chNum}",
        MixerEndpoint.scene: "scene/{sceneNum}"
    ]

    /**
     OSC Argument templates for each method.
     */
    static let oscArgumentTemplates = [
        MixerMethod.assign: "{ON|OFF}",
        MixerMethod.balance: "{-100..100}",
        MixerMethod.level: "{-100..10}",
        MixerMethod.mute: "{ON|OFF}",
        MixerMethod.pan: "{-100..100}",
        MixerMethod.sendLevel: "{-100..10}",
        MixerMethod.trigger: "{PRESS|RELEASE}"
    ]

    /**
     Return a dictionary of OSC Address templates for the given operation. Each
     endpoint type supported by the operation will be a key in the result
     dictionary with a value of the address template.
     */
    static func addressTemplatesFor(mixerConfig: MixerConfig, method: MixerMethod) -> [MixerEndpoint: String] {
        var methodTemplate = "\(method)"
        if method.hasDest { methodTemplate = "to/{dest}/\(method)" }
        return mixerConfig.channelsFor(method).reduce(into: [:]) {
            $0[$1] = "/\(oscAddressTemplates[$1]!)/\(methodTemplate)"
        }
    }
}
