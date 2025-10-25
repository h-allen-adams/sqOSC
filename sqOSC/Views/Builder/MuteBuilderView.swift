//
//  MuteBuilderView.swift
//  sqOSC
//
//  Created by H Allen Adams on 9/12/25.
//

import SwiftUI

/**
 This view contains message builder options for mute operations
 */
struct MuteBuilderView: View {
    let mixerConfig: MixerConfig
    let method: MixerMethod

    @ObservedObject var dictionary: SqMixerEndpointDictionary
    @Binding var resolvedMessage: String
    @Binding var resolvedEvent: AttributedString
    @Preference(\.midiChannel) var midiChannel
    @State private var selectedChannelType: MixerEndpoint
    @State private var selectedChannelNum: Int = 1
    @State private var selectedToggle: SqToggleAction = .ON

    init(dictionary: SqMixerEndpointDictionary,
         resolvedMessage: Binding<String>,
         resolvedEvent: Binding<AttributedString>)
    {
        let mixerConfig = dictionary.mixerConfig
        let method = MixerMethod.mute
        self.dictionary = dictionary
        self.mixerConfig = mixerConfig
        self.method = method
        self._resolvedMessage = resolvedMessage
        self._resolvedEvent = resolvedEvent
        self.selectedChannelType = mixerConfig.channelsFor(method).first ?? .input
    }

    var body: some View {
        VStack {
            Picker("Channel Type", selection: $selectedChannelType) {
                ForEach(mixerConfig.channelsFor(method)) { endpoint in
                    Text(endpoint.rawValue)
                }
            }
            .pickerStyle(.segmented)
            HStack {
                Picker("Channel Num", selection: $selectedChannelNum) {
                    ForEach(Array(1 ... mixerConfig.channelCount(selectedChannelType)!), id: \.self) {
                        Text("\($0)")
                    }
                }
                .pickerStyle(.menu)
                Picker("Toggle", selection: $selectedToggle) {
                    ForEach(SqToggleAction.allCases, id: \.self) {
                        Text("\(String(describing: $0))")
                    }
                }
                .pickerStyle(.segmented)
            }
        }
        .onAppear {
            updateResolvedMessage()
        }
        .onChange(of: selectedChannelType) { _, _ in
            updateResolvedMessage()
        }
        .onChange(of: selectedChannelNum) { _, _ in
            updateResolvedMessage()
        }
        .onChange(of: selectedToggle) { _, _ in
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
        resolvedMessage = address + " \(selectedToggle)"

        let mixerMessages = dictionary.mixerMessages!
        let event = mixerMessages.muteMessage(midiChannel: midiChannel,
                                              type: selectedChannelType,
                                              channel: selectedChannelNum,
                                              action: selectedToggle)
        resolvedEvent = AttributedString(MidiMessagePublisher.toString(event))
        MidiMessageViewUtilities.colorizeNrpn(&resolvedEvent)
    }
}

#Preview {
    @Previewable @State var resolvedEvent = AttributedString("")
    @Previewable @State var resolvedMessage = ""
    MuteBuilderView(dictionary: SqMixerEndpointDictionary.forConfiguration(.sq),
                    resolvedMessage: $resolvedMessage,
                    resolvedEvent: $resolvedEvent)
}
