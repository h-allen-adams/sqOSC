//
//  MuteBuilderView.swift
//  sqOSC
//
//  Created by H Allen Adams on 9/12/25.
//

import SwiftUI

struct MuteBuilderView: View {
    let mixerConfig: SqMixerConfig
    let dictionary: SqMixerEndpointDictionary
    let operation: EndpointOperationType

    @Binding var resolvedPath: String
    @State private var selectedChannelType: EndpointType
    @State private var selectedChannelNum: Int = 1
    @State private var selectedToggle: String = "ON"

    init(dictionary: SqMixerEndpointDictionary, resolvedPath: Binding<String>) {
        let mixerConfig = SqMixerConfig.singletonInstance()
        let operation = EndpointOperationType.mute
        self.dictionary = dictionary
        self.mixerConfig = mixerConfig
        self.operation = operation
        self._resolvedPath = resolvedPath
        self.selectedChannelType = mixerConfig.channelsFor(operation).first!
    }

    var body: some View {
        VStack {
            Picker("Channel Type", selection: $selectedChannelType) {
                ForEach(mixerConfig.channelsFor(operation)) { endpoint in
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
                    ForEach(["ON", "OFF"], id: \.self) {
                        Text("\($0)")
                    }
                }
                .pickerStyle(.segmented)
            }
        }
        .onAppear {
            updateResolvedPath()
        }
        .onChange(of: selectedChannelType) { _, _ in
            updateResolvedPath()
        }
        .onChange(of: selectedChannelNum) { _, _ in
            updateResolvedPath()
        }
        .onChange(of: selectedToggle) { _, _ in
            updateResolvedPath()
        }
    }

    func updateResolvedPath() {
        let pathValues = [
            "chNum": "\(selectedChannelNum)"
        ]
        resolvedPath = dictionary.resolvePath(operation: operation, endpoint: selectedChannelType, pathValues: pathValues)!
            + " \(selectedToggle)"
    }
}

#Preview {
    @Previewable @State var resolvedPath = ""
    MuteBuilderView(dictionary: SqMixerEndpointDictionary(), resolvedPath: $resolvedPath)
}
