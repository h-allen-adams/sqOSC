//
//  MuteBuilderView.swift
//  sqOSC
//
//  Created by H Allen Adams on 9/12/25.
//

import SwiftUI

struct SceneRecallBuilderView: View {
    let mixerConfig: MixerConfig
    let method: MixerMethod

    @ObservedObject var dictionary: SqMixerEndpointDictionary
    @Binding var resolvedMessage: String
    @Binding var resolvedEvent: AttributedString
    @Preference(\.midiChannel) var midiChannel
    @State private var selectedChannelType: MixerEndpoint
    @State private var selectedSceneNum: Int = 1

    init(dictionary: SqMixerEndpointDictionary,
         resolvedMessage: Binding<String>,
         resolvedEvent: Binding<AttributedString>)
    {
        let mixerConfig = dictionary.mixerConfig
        let method = MixerMethod.recall
        self.dictionary = dictionary
        self.mixerConfig = mixerConfig
        self.method = method
        self._resolvedMessage = resolvedMessage
        self._resolvedEvent = resolvedEvent
        self.selectedChannelType = mixerConfig.channelsFor(method).first ?? .scene
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Scene Num")
                Picker("", selection: $selectedSceneNum) {
                    ForEach(Array(1 ... mixerConfig.channelCount(selectedChannelType)!), id: \.self) {
                        Text("\($0)")
                    }
                }
                .pickerStyle(.menu)
                .labelsHidden()
            }
        }
        .onAppear {
            updateResolvedMessage()
        }
        .onChange(of: selectedChannelType) { _, _ in
            updateResolvedMessage()
        }
        .onChange(of: selectedSceneNum) { _, _ in
            updateResolvedMessage()
        }
        .flexibleButtonSizing()
    }

    func updateResolvedMessage() {
        resolvedMessage =
            dictionary.resolveOscAddress(method: method,
                                         endpoint: selectedChannelType,
                                         templateValues: ["sceneNum": "\(selectedSceneNum)"]) ?? "/none"

        guard let mixerMessages = dictionary.mixerMessages else { return }
        let event = mixerMessages.sceneRecallMessage(midiChannel: midiChannel,
                                                     scene: selectedSceneNum)
        resolvedEvent = AttributedString(MidiMessagePublisher.toString(event))
    }
}

#Preview {
    @Previewable @State var resolvedEvent = AttributedString("")
    @Previewable @State var resolvedMessage = ""
    SceneRecallBuilderView(dictionary: SqMixerEndpointDictionary.forConfiguration(.sq, faderLaw: .LinearTaper),
                           resolvedMessage: $resolvedMessage,
                           resolvedEvent: $resolvedEvent)
}
