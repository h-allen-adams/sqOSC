//
//  MuteBuilderView.swift
//  sqOSC
//
//  Created by H Allen Adams on 9/12/25.
//

import SwiftUI

struct ChannelValueRangeBuilderView: View {
    let mixerConfig: SqMixerConfig
    let dictionary: SqMixerEndpointDictionary
    let operation: EndpointOperationType

    @Binding var resolvedPath: String
    @State private var selectedChannelType: EndpointType
    @State private var selectedChannelNum: Int = 1
    @State private var selectedValue = 0.0

    init(operation: EndpointOperationType, dictionary: SqMixerEndpointDictionary, resolvedPath: Binding<String>) {
        let mixerConfig = SqMixerConfig.singletonInstance()
        self.mixerConfig = mixerConfig
        self.operation = operation
        self.dictionary = dictionary
        self._resolvedPath = resolvedPath

        let source = mixerConfig.channelsFor(operation).first!
        self.selectedChannelType = source
    }

    var body: some View {
        VStack {
            Picker("Channel Type", selection: $selectedChannelType) {
                ForEach(mixerConfig.channelsFor(operation)) { endpoint in
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
            Slider(value: $selectedValue, in: operation.valueRange) {
                Text("Value")
            } minimumValueLabel: {
                Text("\(Int(operation.valueRange.lowerBound))\(operation.units)")
            } maximumValueLabel: {
                Text("\(Int(operation.valueRange.upperBound))\(operation.units)")
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
        }.onChange(of: selectedValue) { _, _ in
            updateResolvedPath()
        }
    }

    func updateResolvedPath() {
        let pathValues = [
            "chNum": "\(selectedChannelNum)"
        ]
        resolvedPath = dictionary.resolvePath(operation: operation, endpoint: selectedChannelType, pathValues: pathValues)!
            + " \(Int(selectedValue))"
    }
}

#Preview {
    @Previewable @State var resolvedPath = ""
    ChannelValueRangeBuilderView(operation: .balance, dictionary: SqMixerEndpointDictionary(), resolvedPath: $resolvedPath)
}
