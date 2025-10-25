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
    @State private var selectedChannelType: MixerEndpoint
    @State private var selectedChannelNum: Int = 1
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

        let source = mixerConfig.channelsFor(method).first!
        self.selectedChannelType = source
    }

    var body: some View {
        VStack {
            Picker("Channel Type", selection: $selectedChannelType) {
                ForEach(mixerConfig.channelsFor(method)) { endpoint in
                    Text(endpoint.rawValue)
                }
            }
            .pickerStyle(.segmented)

            Picker("Channel Num", selection: $selectedChannelNum) {
                ForEach(Array(1 ... mixerConfig.channelCount(selectedChannelType)!), id: \.self) {
                    Text("\($0)")
                }
            }
            .pickerStyle(.menu)
            Slider(value: $selectedValue, in: method.valueRange) {
                Text("Value")
            } minimumValueLabel: {
                Text("\(Int(method.valueRange.lowerBound))\(method.units)")
            } maximumValueLabel: {
                Text("\(Int(method.valueRange.upperBound))\(method.units)")
            }
        }
        .onAppear {
            updateResolvedMessage()
        }
        .onChange(of: selectedChannelType) { _, _ in
            selectedChannelNum = 1
            updateResolvedMessage()
        }.onChange(of: selectedChannelNum) { _, _ in
            updateResolvedMessage()
        }.onChange(of: selectedValue) { _, _ in
            updateResolvedMessage()
        }
    }

    func updateResolvedMessage() {
        let templateValues = [
            "chNum": "\(selectedChannelNum)"
        ]

        let address = dictionary.resolveOscAddress(method: method,
                                                   endpoint: selectedChannelType,
                                                   templateValues: templateValues) ?? "/none"
        resolvedMessage = address + " \(Int(selectedValue))"

        let mixerMessages = dictionary.mixerMessages!

        switch method {
        case .balance:
            let event = mixerMessages.outputBalanceMessage(midiChannel: midiChannel,
                                                           outputType: selectedChannelType,
                                                           outputChannel: selectedChannelNum,
                                                           panLevel: Int(selectedValue))
            resolvedEvent = AttributedString(MidiMessagePublisher.toString(event))
        case .level:
            let event = mixerMessages.outputLevelMessage(midiChannel: midiChannel,
                                                         outputType: selectedChannelType,
                                                         outputChannel: selectedChannelNum,
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
