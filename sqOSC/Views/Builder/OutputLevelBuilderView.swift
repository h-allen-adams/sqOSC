//
//  MuteBuilderView.swift
//  sqOSC
//
//  Created by H Allen Adams on 9/12/25.
//

import SwiftUI

struct OutputLevelBuilderView: View {
    let dictionary: SqMixerEndpointDictionary
    let operation: EndpointOperationType = .level
    @Binding var resolvedPath: String
    @EnvironmentObject var mixerConfig: SqMixerConfig
    @State private var selectedChannelType: EndpointType = EndpointOperationType.level.endpoints.first!
    @State private var selectedChannelNum: Int = 1
    @State private var selectedSendLevel = 0.0

    var body: some View {
        VStack {
            Picker("Channel Type", selection: $selectedChannelType) {
                ForEach(operation.endpoints) { endpoint in
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
            Slider(value: $selectedSendLevel, in: -100 ... 10) {
                Text("Output Level")
            } minimumValueLabel: {
                Text("-100dB")
            } maximumValueLabel: {
                Text("10dB")
            }
        }
        .onAppear {
            updateResolvedPath()
        }
        .onChange(of: selectedChannelType) { _, _ in
            selectedChannelNum = 1
            updateResolvedPath()
        }.onChange(of: selectedChannelNum) { _, _ in
            updateResolvedPath()
        }
        .onChange(of: selectedSendLevel) { _, _ in
            updateResolvedPath()
        }
    }

    func updateResolvedPath() {
        let pathValues = [
            "chNum": "\(selectedChannelNum)"
        ]
        resolvedPath = dictionary.resolvePath(operation: operation, endpoint: selectedChannelType, pathValues: pathValues)!
            + " \(Int(selectedSendLevel))"
    }
}

#Preview {
    @Previewable @State var resolvedPath = ""
    OutputLevelBuilderView(dictionary: SqMixerEndpointDictionary(mixerConfig: SqMixerConfig.defaultConfig()), resolvedPath: $resolvedPath)
}
