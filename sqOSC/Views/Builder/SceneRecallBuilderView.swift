//
//  MuteBuilderView.swift
//  sqOSC
//
//  Created by H Allen Adams on 9/12/25.
//

import SwiftUI

struct SceneRecallBuilderView: View {
    let mixerConfig: MixerConfig
    let dictionary: SqMixerEndpointDictionary
    let method: MixerMethod

    @Binding var resolvedMessage: String
    @State private var selectedChannelType: MixerEndpoint
    @State private var selectedSceneNum: Int = 1

    init(dictionary: SqMixerEndpointDictionary, resolvedMessage: Binding<String>) {
        let mixerConfig = dictionary.mixerConfig
        let method = MixerMethod.recall
        self.dictionary = dictionary
        self.mixerConfig = mixerConfig
        self.method = method
        self._resolvedMessage = resolvedMessage
        self.selectedChannelType = mixerConfig.channelsFor(method).first!
    }

    var body: some View {
        VStack {
            HStack {
                Picker("Scene Num", selection: $selectedSceneNum) {
                    ForEach(Array(1 ... mixerConfig.channelCount(selectedChannelType)!), id: \.self) {
                        Text("\($0)")
                    }
                }
                .pickerStyle(.menu)
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
    }

    func updateResolvedMessage() {
        resolvedMessage =
            dictionary.resolveOscAddress(method: method,
                                         endpoint: selectedChannelType,
                                         templateValues: ["sceneNum": "\(selectedSceneNum)"])!
    }
}

#Preview {
    @Previewable @State var resolvedMessage = ""
    SceneRecallBuilderView(dictionary: SqMixerEndpointDictionary(.sq),
                           resolvedMessage: $resolvedMessage)
}
