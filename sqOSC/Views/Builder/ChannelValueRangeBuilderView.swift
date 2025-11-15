//
//  MuteBuilderView.swift
//  sqOSC
//
//  Created by H Allen Adams on 9/12/25.
//

import SwiftUI

/**
 This view displays message builder options for single-channel
 operations.
 */
struct ChannelValueRangeBuilderView: View {
    let mixerConfig: MixerConfig
    let method: MixerMethod

    @ObservedObject var dictionary: SqMixerEndpointDictionary
    @Binding var resolvedMessage: String
    @Binding var resolvedEvent: AttributedString
    @Preference(\.midiChannel) var midiChannel
    @State private var selectedChannelType: MixerConfig.BuilderChannelType
    @State private var selectedChannel: MixerConfig.BuilderChannel
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

        let initialChannelType = mixerConfig.builderChannelTypeFor(method).first ?? .input
        self.selectedChannelType = initialChannelType
        self.selectedChannel = mixerConfig.builderChannels(initialChannelType).first ?? MixerConfig.BuilderChannel.UNRESOLVED
    }

    var body: some View {
        VStack {
            HStack {
                Text("Channel")
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

            HStack {
                Text("Value")
                Slider(value: $selectedValue, in: method.valueRange) {} minimumValueLabel: {
                    Text("\(Int(method.valueRange.lowerBound))\(method.units)")
                } maximumValueLabel: {
                    Text("\(Int(method.valueRange.upperBound))\(method.units)")
                }
                .labelsHidden()
            }
        }
        .onAppear {
            updateResolvedMessage()
        }
        .onChange(of: selectedChannelType) { _, _ in
            selectedChannel = mixerConfig.builderChannels(selectedChannelType).first!
            updateResolvedMessage()
        }.onChange(of: selectedChannel) { _, _ in
            updateResolvedMessage()
        }.onChange(of: selectedValue) { _, _ in
            updateResolvedMessage()
        }
    }

    func updateResolvedMessage() {
        let templateValues = [
            "chNum": "\(selectedChannel.chNum)"
        ]

        let address = dictionary.resolveOscAddress(method: method,
                                                   endpoint: selectedChannel.endpoint,
                                                   templateValues: templateValues) ?? "/none"
        resolvedMessage = address + " \(Int(selectedValue))"

        guard let mixerMessages = dictionary.mixerMessages else { return }

        switch method {
        case .balance:
            let event = mixerMessages.outputBalanceMessage(midiChannel: midiChannel,
                                                           outputType: selectedChannel.endpoint,
                                                           outputChannel: selectedChannel.chNum,
                                                           panLevel: Int(selectedValue))
            resolvedEvent = AttributedString(MidiMessagePublisher.toString(event))
        case .level:
            let event = mixerMessages.outputLevelMessage(midiChannel: midiChannel,
                                                         outputType: selectedChannel.endpoint,
                                                         outputChannel: selectedChannel.chNum,
                                                         dbLevel: Int(selectedValue))
            resolvedEvent = AttributedString(MidiMessagePublisher.toString(event))
        default:
            break
        }

        MidiMessageViewUtilities.colorizeNrpn(&resolvedEvent)
    }
}

#Preview {
    @Previewable @State var resolvedEvent = AttributedString("")
    @Previewable @State var resolvedMessage = ""
    ChannelValueRangeBuilderView(method: .balance,
                                 dictionary: SqMixerEndpointDictionary.forConfiguration(.sq),
                                 resolvedMessage: $resolvedMessage,
                                 resolvedEvent: $resolvedEvent)
}
