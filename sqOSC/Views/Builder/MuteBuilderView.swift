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
    @State private var selectedChannelType: MixerConfig.BuilderChannelType
    @State private var selectedChannel: MixerConfig.BuilderChannel
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
                Text("Mute")
                Picker("", selection: $selectedToggle) {
                    ForEach(SqToggleAction.allCases, id: \.self) {
                        Text("\(String(describing: $0))")
                    }
                }
                .labelsHidden()
                .pickerStyle(.segmented)
            }
        }
        .onAppear {
            updateResolvedMessage()
        }
        .onChange(of: selectedChannelType) { _, _ in
            selectedChannel = mixerConfig.builderChannels(selectedChannelType).first!
            updateResolvedMessage()
        }
        .onChange(of: selectedChannel) { _, _ in
            selectedToggle = .ON
            updateResolvedMessage()
        }
        .onChange(of: selectedToggle) { _, _ in
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
        resolvedMessage = address + " \(selectedToggle)"

        guard let mixerMessages = dictionary.mixerMessages else { return }
        let event = mixerMessages.muteMessage(midiChannel: midiChannel,
                                              type: selectedChannel.endpoint,
                                              channel: selectedChannel.chNum,
                                              action: selectedToggle)
        resolvedEvent = AttributedString(MidiMessagePublisher.toString(event))
        MidiMessageViewUtilities.colorizeNrpn(&resolvedEvent)
    }
}

#Preview {
    @Previewable @State var resolvedEvent = AttributedString("")
    @Previewable @State var resolvedMessage = ""
    MuteBuilderView(dictionary: SqMixerEndpointDictionary.forConfiguration(.qu),
                    resolvedMessage: $resolvedMessage,
                    resolvedEvent: $resolvedEvent)
}
