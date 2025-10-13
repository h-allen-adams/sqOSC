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
    @State private var selectedChannelType: MixerEndpoint
    @State private var selectedChannelNum: Int = 1
    @State private var selectedToggle: String = "PRESS"

    init(dictionary: SqMixerEndpointDictionary, resolvedMessage: Binding<String>) {
        let mixerConfig = dictionary.mixerConfig
        let method = MixerMethod.trigger
        self.dictionary = dictionary
        self.method = method
        self.mixerConfig = mixerConfig
        self._resolvedMessage = resolvedMessage
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
    }
}

#Preview {
    @Previewable @State var resolvedMessage = ""
    SoftkeyBuilderView(dictionary: SqMixerEndpointDictionary(.sq),
                       resolvedMessage: $resolvedMessage)
}
