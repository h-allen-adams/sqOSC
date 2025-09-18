//
//  MuteBuilderView.swift
//  sqOSC
//
//  Created by H Allen Adams on 9/12/25.
//

import SwiftUI

struct SendPanBuilderView: View {
    let dictionary: SqMixerEndpointDictionary
    let operation: EndpointOperationType = .pan
    @Binding var resolvedPath: String
    @EnvironmentObject var mixerConfig: SqMixerConfig
    @State private var selectedChannelType: EndpointType = EndpointOperationType.pan.endpoints.first!
    @State private var selectedChannelNum: Int = 1
    @State private var selectedDestType: EndpointType = EndpointOperationType.pan.endpoints.first!.panTargets.first!
    @State private var selectedDestNum: Int = 1
    @State private var selectedSendPan = 0.0

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
            ForEach(selectedChannelType.panTargets) {
                Text(verbatim: "\($0)")
            }
        }
        .pickerStyle(.segmented)
    }

    func destNumPicker() -> some View {
        Picker("Dest Num", selection: $selectedDestNum) {
            ForEach(Array(1 ... mixerConfig.channelCount(selectedDestType)!), id: \.self) {
                Text("\($0)")
            }
        }
        .pickerStyle(.menu)
    }

    func sendPanSlider() -> some View {
        Slider(value: $selectedSendPan, in: -100 ... 100) {
            Text("Send Pan")
        } minimumValueLabel: {
            Text("L 100%")
        } maximumValueLabel: {
            Text("R 100%")
        }
    }

    var body: some View {
        VStack {
            channelTypePicker()
            channelNumPicker()
            destTypePicker()
            destNumPicker()
            sendPanSlider()
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
            selectedSendPan = 0
            updateResolvedPath()
        }
        .onChange(of: selectedSendPan) { _, _ in
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
            + " \(Int(selectedSendPan))"
    }
}

#Preview {
    @Previewable @State var resolvedPath = ""
    SendPanBuilderView(dictionary: SqMixerEndpointDictionary(mixerConfig: SqMixerConfig.defaultConfig()), resolvedPath: $resolvedPath)
}
