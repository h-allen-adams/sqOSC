//
//  MuteBuilderView.swift
//  sqOSC
//
//  Created by H Allen Adams on 9/12/25.
//

import SwiftUI

/**
 This view displays message builder options for channel-to-channel
 operations (sendLevel, pan).
 */
struct ChannelToChannelValueRangeBuilderView: View {
    let mixerConfig: MixerConfig
    let method: MixerMethod

    @ObservedObject var dictionary: SqMixerEndpointDictionary
    @Binding var resolvedMessage: String
    @Binding var resolvedEvent: AttributedString
    @Preference(\.midiChannel) var midiChannel
    @State private var selectedChannelType: MixerEndpoint
    @State private var selectedDestType: MixerEndpoint
    @State private var selectedChannelNum: Int = 1
    @State private var selectedDestNum: Int = 1
    @State private var selectedValue = 0.0

    init(method: MixerMethod,
         dictionary: SqMixerEndpointDictionary,
         resolvedMessage: Binding<String>,
         resolvedEvent: Binding<AttributedString>)
    {
        let mixerConfig = dictionary.mixerConfig
        self.mixerConfig = mixerConfig
        self.method = method
        self.dictionary = dictionary
        self._resolvedMessage = resolvedMessage
        self._resolvedEvent = resolvedEvent

        let source = mixerConfig.channelsFor(method).first ?? .input
        self.selectedChannelType = source
        self.selectedDestType = mixerConfig.channelTargets(method, source: source).first ?? .input
    }

    var body: some View {
        VStack {
            channelTypePicker()
            channelNumPicker()
            destTypePicker()
            destNumPicker()
            sendValueSlider()
        }
        .onAppear {
            updateResolvedMessage()
        }
        .onChange(of: selectedChannelType) { _, _ in
            selectedChannelNum = 1
            selectedDestType = mixerConfig.channelTargets(method, source: selectedChannelType).first!
            updateResolvedMessage()
        }.onChange(of: selectedChannelNum) { _, _ in
            updateResolvedMessage()
        }.onChange(of: selectedDestType) { _, _ in
            selectedDestNum = 1
            updateResolvedMessage()
        }
        .onChange(of: selectedDestNum) { _, _ in
            selectedValue = 0
            updateResolvedMessage()
        }
        .onChange(of: selectedValue) { _, _ in
            updateResolvedMessage()
        }
    }

    /**
     Source Channel Type Picker
     */
    func channelTypePicker() -> some View {
        Picker("Source Type", selection: $selectedChannelType) {
            ForEach(mixerConfig.channelsFor(method)) { endpoint in
                Text(endpoint.rawValue)
            }
        }
        .pickerStyle(.segmented)
    }

    /**
     Source Channel Number Picker
     */
    func channelNumPicker() -> some View {
        Picker("Source Num", selection: $selectedChannelNum) {
            ForEach(Array(1 ... mixerConfig.channelCount(selectedChannelType)!), id: \.self) {
                Text("\($0)")
            }
        }
        .pickerStyle(.menu)
    }

    /**
     Destination Channel Type Picker
     */
    func destTypePicker() -> some View {
        Picker("Dest Type", selection: $selectedDestType) {
            ForEach(mixerConfig.channelTargets(method, source: selectedChannelType)) {
                Text(verbatim: "\($0)")
            }
        }
        .pickerStyle(.segmented)
    }

    /**
     Destinateion Channel Number Picker
     */
    func destNumPicker() -> some View {
        Picker("Dest Num", selection: $selectedDestNum) {
            ForEach(Array(1 ... mixerConfig.channelCount(selectedDestType)!), id: \.self) {
                Text("\($0)")
            }
        }
        .pickerStyle(.menu)
    }

    /**
     Value Picker
     */
    func sendValueSlider() -> some View {
        Slider(value: $selectedValue, in: method.valueRange) {
            Text("Value")
        } minimumValueLabel: {
            Text("\(Int(method.valueRange.lowerBound))\(method.units)")
        } maximumValueLabel: {
            Text("\(Int(method.valueRange.upperBound))\(method.units)")
        }
    }

    /**
     Update the resolvedPath when any of the picker values changes
     */
    func updateResolvedMessage() {
        var dest = "\(selectedDestType)/\(selectedDestNum)"
        if mixerConfig.channelCount(selectedDestType)! == 1 {
            dest = "\(selectedDestType)"
        }
        let pathValues = [
            "chNum": "\(selectedChannelNum)",
            "dest": dest
        ]
        let address = dictionary.resolveOscAddress(method: method,
                                                   endpoint: selectedChannelType,
                                                   templateValues: pathValues) ?? "/none"
        resolvedMessage = address + " \(Int(selectedValue))"

        let mixerMessages = dictionary.mixerMessages!

        switch method {
        case .pan:
            let event = mixerMessages.sendPanMessage(midiChannel: midiChannel,
                                                     sourceType: selectedChannelType,
                                                     sourceChannel: selectedChannelNum,
                                                     destType: selectedDestType,
                                                     destChannel: selectedDestNum,
                                                     panLevel: Int(selectedValue))
            resolvedEvent = AttributedString(MidiMessagePublisher.toString(event))
        case .sendLevel:
            let event = mixerMessages.sendLevelMessage(midiChannel: midiChannel,
                                                       sourceType: selectedChannelType,
                                                       sourceChannel: selectedChannelNum,
                                                       destType: selectedDestType,
                                                       destChannel: selectedDestNum,
                                                       dbLevel: Int(selectedValue))
            resolvedEvent = AttributedString(MidiMessagePublisher.toString(event))
        default:
            break
        }

        MidiMessageViewUtilities.colorizeNrpn(&resolvedEvent)
    }
}

#Preview {
    @Previewable @State var resolvedMessage = ""
    @Previewable @State var resolvedEvent = AttributedString("")
    ChannelToChannelValueRangeBuilderView(method: .pan,
                                          dictionary: SqMixerEndpointDictionary.forConfiguration(.sq),
                                          resolvedMessage: $resolvedMessage,
                                          resolvedEvent: $resolvedEvent)
}
