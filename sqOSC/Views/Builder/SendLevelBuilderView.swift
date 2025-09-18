//
//  MuteBuilderView.swift
//  sqOSC
//
//  Created by H Allen Adams on 9/12/25.
//

import SwiftUI

struct SendLevelBuilderView: View {
    let dictionary: SqMixerEndpointDictionary
    let operation: EndpointOperationType = .sendLevel
    @Binding var resolvedPath: String
    @EnvironmentObject var mixerConfig: SqMixerConfig
    @State private var selectedChannelType: EndpointType = EndpointOperationType.sendLevel.endpoints.first!
    @State private var selectedChannelNum: Int = 1
    @State private var selectedDestType: EndpointType = EndpointOperationType.sendLevel.endpoints.first!.sendTargets.first!
    @State private var selectedDestNum: Int = 1
    @State private var selectedSendLevel = 0.0

    func channelTypePicker() -> some View {
        Picker("Channel Type", selection: $selectedChannelType) {
            ForEach(operation.endpoints) { endpoint in
                Text(endpoint.rawValue)
            }
        }
        .pickerStyle(.segmented)
    }

    func channelNumPicker() -> some View {
        Picker("Channel Num", selection: $selectedChannelNum) {
            ForEach(Array(1 ... mixerConfig.channelCount(selectedChannelType)!), id: \.self) {
                Text("\($0)")
            }
        }
        .pickerStyle(.menu)
    }

    func destTypePicker() -> some View {
        Picker("Dest Type", selection: $selectedDestType) {
            ForEach(selectedChannelType.sendTargets) {
                Text(verbatim: "\($0)")
            }
        }
        .pickerStyle(.segmented)
    }

    func destNumPicker() -> some View {
        Picker("Dest Num", selection: $selectedDestNum) {
            ForEach(Array(1 ... mixerConfig.channelCount(selectedDestType)!), id: \.self) {
                Text(verbatim: "\($0)")
            }
        }
        .pickerStyle(.menu)
    }

    func sendLevelSlider() -> some View {
        Slider(value: $selectedSendLevel, in: -100 ... 10) {
            Text("Send Level")
        } minimumValueLabel: {
            Text("-100dB")
        } maximumValueLabel: {
            Text("10dB")
        }
    }

    var body: some View {
        VStack {
            channelTypePicker()
            channelNumPicker()
            destTypePicker()
            destNumPicker()
            sendLevelSlider()
        }
        .onAppear {
            updateResolvedPath()
        }
        .onChange(of: selectedChannelType) { _, _ in
            selectedChannelNum = 1
            selectedDestType = selectedChannelType.sendTargets.first!
            updateResolvedPath()
        }.onChange(of: selectedChannelNum) { _, _ in
            updateResolvedPath()
        }.onChange(of: selectedDestType) { _, _ in
            selectedDestNum = 1
            updateResolvedPath()
        }
        .onChange(of: selectedDestNum) { _, _ in
            selectedSendLevel = 0
            updateResolvedPath()
        }
        .onChange(of: selectedSendLevel) { _, _ in
            updateResolvedPath()
        }
    }

    func updateResolvedPath() {
        var dest = "\(selectedDestType)/\(selectedDestNum)"
        if mixerConfig.channelCount(selectedDestType)! == 1 {
            dest = "\(selectedDestType)"
        }
        let pathValues = [
            "chNum": "\(selectedChannelNum)",
            "dest": dest
        ]
        resolvedPath = dictionary.resolvePath(operation: operation, endpoint: selectedChannelType, pathValues: pathValues)!
            + " \(Int(selectedSendLevel))"
    }
}

#Preview {
    @Previewable @State var resolvedPath = ""
    SendLevelBuilderView(dictionary: SqMixerEndpointDictionary(mixerConfig: SqMixerConfig.defaultConfig()), resolvedPath: $resolvedPath)
}
