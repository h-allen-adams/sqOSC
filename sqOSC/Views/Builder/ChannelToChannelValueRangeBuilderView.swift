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
    @State private var selectedChannelType: MixerConfig.BuilderChannelType
    @State private var selectedChannel: MixerConfig.BuilderChannel
    @State private var selectedDestType: MixerConfig.BuilderChannelType
    @State private var selectedDest: MixerConfig.BuilderChannel
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

        let source = mixerConfig.builderChannelTypeFor(method).first ?? .input
        self.selectedChannelType = source
        self.selectedChannel = mixerConfig.builderChannels(source).first ?? MixerConfig.BuilderChannel.UNRESOLVED

        let dest = mixerConfig.builderChannelTargets(method, source: source).first!
        self.selectedDestType = dest
        self.selectedDest = mixerConfig.builderChannels(dest).first ?? MixerConfig.BuilderChannel.UNRESOLVED
    }

    var body: some View {
        VStack {
            sourcePicker()
            destPicker()
            sendValueSlider()
        }
        .onAppear {
            updateResolvedMessage()
        }
        .onChange(of: selectedChannelType) { _, _ in
            selectedChannel = mixerConfig.builderChannels(selectedChannelType).first!
            selectedDestType = mixerConfig.builderChannelTargets(method, source: selectedChannelType).first!
            selectedDest = mixerConfig.builderChannels(selectedDestType).first!
            updateResolvedMessage()
        }.onChange(of: selectedChannel) { _, _ in
            updateResolvedMessage()
        }.onChange(of: selectedDestType) { _, _ in
            selectedDest = mixerConfig.builderChannels(selectedDestType).first!
            updateResolvedMessage()
        }
        .onChange(of: selectedDest) { _, _ in
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
    func sourcePicker() -> some View {
        HStack {
            Text("Source")
            Picker("", selection: $selectedChannelType) {
                ForEach(mixerConfig.builderChannelTypeFor(method)) { channelType in
                    Text(channelType.title)
                }
            }
            .labelsHidden()
            Picker("", selection: $selectedChannel) {
                ForEach(mixerConfig.builderChannels(selectedChannelType), id: \.self) {
                    Text("\($0.title)")
                }
            }
            .labelsHidden()
        }
    }

    /**
     Destination Channel Type Picker
     */
    func destPicker() -> some View {
        HStack {
            Text("Dest")
            Picker("", selection: $selectedDestType) {
                ForEach(mixerConfig.builderChannelTargets(method, source: selectedChannelType)) { channelType in
                    Text(channelType.title)
                }
            }
            .labelsHidden()
            Picker("", selection: $selectedDest) {
                ForEach(mixerConfig.builderChannels(selectedDestType), id: \.self) {
                    Text("\($0.title)")
                }
            }
            .labelsHidden()
        }
    }

    /**
     Value Picker
     */
    func sendValueSlider() -> some View {
        HStack {
            Text("Value")
            Slider(value: $selectedValue, in: method.valueRange) {} minimumValueLabel: {
                Text("\(Int(method.valueRange.lowerBound))\(method.units)")
            } maximumValueLabel: {
                Text("\(Int(method.valueRange.upperBound))\(method.units)")
            }
        }
    }

    /**
     Update the resolvedPath when any of the picker values changes
     */
    func updateResolvedMessage() {
        var dest = "\(selectedDest.endpoint)/\(selectedDest.chNum)"
        if mixerConfig.channelCount(selectedDest.endpoint)! == 1 {
            dest = "\(selectedDest.endpoint)"
        }
        let pathValues = [
            "chNum": "\(selectedChannel.chNum)",
            "dest": dest
        ]

        let address = dictionary.resolveOscAddress(method: method,
                                                   endpoint: selectedChannel.endpoint,
                                                   templateValues: pathValues) ?? "/none"
        resolvedMessage = address + " \(Int(selectedValue))"

        guard let mixerMessages = dictionary.mixerMessages else { return }

        switch method {
        case .pan:
            let event = mixerMessages.sendPanMessage(midiChannel: midiChannel,
                                                     sourceType: selectedChannel.endpoint,
                                                     sourceChannel: selectedChannel.chNum,
                                                     destType: selectedDest.endpoint,
                                                     destChannel: selectedDest.chNum,
                                                     panLevel: Int(selectedValue))
            resolvedEvent = AttributedString(MidiMessagePublisher.toString(event))
        case .sendLevel:
            let event = mixerMessages.sendLevelMessage(midiChannel: midiChannel,
                                                       sourceType: selectedChannel.endpoint,
                                                       sourceChannel: selectedChannel.chNum,
                                                       destType: selectedDest.endpoint,
                                                       destChannel: selectedDest.chNum,
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
