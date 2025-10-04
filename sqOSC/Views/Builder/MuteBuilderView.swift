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
    let mixerConfig: SqMixerConfig
    let dictionary: SqMixerEndpointDictionary
    let method: MixerMethod

    @Binding var resolvedMessage: String
    @State private var selectedChannelType: MixerEndpoint
    @State private var selectedChannelNum: Int = 1
    @State private var selectedToggle: SqMuteAction = .ON

    init(dictionary: SqMixerEndpointDictionary, resolvedMessage: Binding<String>) {
        let mixerConfig = SqMixerConfig.singletonInstance()
        let method = MixerMethod.mute
        self.dictionary = dictionary
        self.mixerConfig = mixerConfig
        self.method = method
        self._resolvedMessage = resolvedMessage
        self.selectedChannelType = mixerConfig.channelsFor(method).first!
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
                    ForEach(SqMuteAction.allCases, id: \.self) {
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
        resolvedMessage = dictionary.resolveOscAddress(method: method,
                                                       endpoint: selectedChannelType,
                                                       templateValues: templateValues)!
            + " \(selectedToggle)"
    }
}

#Preview {
    @Previewable @State var resolvedMessage = ""
    MuteBuilderView(dictionary: SqMixerEndpointDictionary(),
                    resolvedMessage: $resolvedMessage)
}
