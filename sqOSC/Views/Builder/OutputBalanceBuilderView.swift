//
//  MuteBuilderView.swift
//  sqOSC
//
//  Created by H Allen Adams on 9/12/25.
//

import SwiftUI

struct OutputBalanceBuilderView: View {
    let dictionary: SqMixerEndpointDictionary
    let operation: EndpointOperationType = .balance
    @Binding var resolvedPath: String
    @EnvironmentObject var mixerConfig: SqMixerConfig
    @State private var selectedChannelType: EndpointType = EndpointOperationType.balance.endpoints.first!
    @State private var selectedChannelNum: Int = 1
    @State private var selectedSendPan = 0.0

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
            Slider(value: $selectedSendPan, in: -100 ... 100) {
                Text("Output Balance")
            } minimumValueLabel: {
                Text("L 100%")
            } maximumValueLabel: {
                Text("R 100%")
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
        }.onChange(of: selectedSendPan) { _, _ in
            updateResolvedPath()
        }
    }

    func updateResolvedPath() {
        let pathValues = [
            "chNum": "\(selectedChannelNum)"
        ]
        resolvedPath = dictionary.resolvePath(operation: operation, endpoint: selectedChannelType, pathValues: pathValues)!
            + " \(Int(selectedSendPan))"
    }
}

#Preview {
    @Previewable @State var resolvedPath = ""
    OutputBalanceBuilderView(dictionary: SqMixerEndpointDictionary(mixerConfig: SqMixerConfig.defaultConfig()), resolvedPath: $resolvedPath)
}
