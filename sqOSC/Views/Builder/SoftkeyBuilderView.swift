//
//  MuteBuilderView.swift
//  sqOSC
//
//  Created by H Allen Adams on 9/12/25.
//

import SwiftUI

struct SoftkeyBuilderView: View {
    let mixerConfig: MixerConfig
    let method: MixerMethod

    @ObservedObject var dictionary: SqMixerEndpointDictionary
    @Binding var resolvedMessage: String
    @Binding var resolvedEvent: AttributedString
    @Preference(\.midiChannel) var midiChannel
    @State private var selectedChannelType: MixerEndpoint
    @State private var selectedChannelNum: Int = 1
    @State private var selectedToggle: String = "PRESS"

    init(dictionary: SqMixerEndpointDictionary,
         resolvedMessage: Binding<String>,
         resolvedEvent: Binding<AttributedString>)
    {
        let mixerConfig = dictionary.mixerConfig
        let method = MixerMethod.trigger
        self.dictionary = dictionary
        self.method = method
        self.mixerConfig = mixerConfig
        self._resolvedMessage = resolvedMessage
        self._resolvedEvent = resolvedEvent
        self.selectedChannelType = mixerConfig.channelsFor(method).first ?? .keys
    }

    var body: some View {
        VStack {
            HStack {
                Picker("SoftKey Num", selection: $selectedChannelNum) {
                    ForEach(Array(1 ... mixerConfig.channelCount(selectedChannelType)!), id: \.self) {
                        Text("\($0)")
                    }
                }
                .pickerStyle(.menu)
                Picker("Toggle", selection: $selectedToggle) {
                    ForEach(["PRESS", "RELEASE"], id: \.self) {
                        Text("\($0)")
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
            "keyNum": "\(selectedChannelNum)"
        ]

        let address = dictionary.resolveOscAddress(method: method,
                                                   endpoint: selectedChannelType,
                                                   templateValues: templateValues) ?? "/none"
        resolvedMessage = address + " \(selectedToggle)"

        let mixerMessages = dictionary.mixerMessages!
        let event = mixerMessages.softKeyMessage(midiChannel: midiChannel,
                                                 button: selectedChannelNum,
                                                 state: SqButtonState(rawValue: selectedToggle)!)
        resolvedEvent = AttributedString(MidiMessagePublisher.toString(event))
    }
}

#Preview {
    @Previewable @State var resolvedEvent = AttributedString("")
    @Previewable @State var resolvedMessage = ""
    SoftkeyBuilderView(dictionary: SqMixerEndpointDictionary.forConfiguration(.sq),
                       resolvedMessage: $resolvedMessage,
                       resolvedEvent: $resolvedEvent)
}
