//
//  MuteBuilderView.swift
//  sqOSC
//
//  Created by H Allen Adams on 9/12/25.
//

import SwiftUI

/**
 This view displays message builder options for channel-to-channel
 operations (sendLevel, pan).
 */
struct ChannelToChannelValueRangeBuilderView: View {
    let mixerConfig: SqMixerConfig
    let dictionary: SqMixerEndpointDictionary
    let operation: EndpointOperationType

    @Binding var resolvedPath: String
    @State private var selectedChannelType: EndpointType
    @State private var selectedDestType: EndpointType
    @State private var selectedChannelNum: Int = 1
    @State private var selectedDestNum: Int = 1
    @State private var selectedValue = 0.0

    init(operation: EndpointOperationType, dictionary: SqMixerEndpointDictionary, resolvedPath: Binding<String>) {
        let mixerConfig = SqMixerConfig.singletonInstance()
        self.mixerConfig = mixerConfig
        self.operation = operation
        self.dictionary = dictionary
        self._resolvedPath = resolvedPath

        let source = mixerConfig.channelsFor(operation).first!
        self.selectedChannelType = source
        self.selectedDestType = mixerConfig.channelTargets(operation, source: source).first!
    }

    var body: some View {
        VStack {
            channelTypePicker()
            channelNumPicker()
            destTypePicker()
            destNumPicker()
            sendValueSlider()
        }
        .onAppear {
            updateResolvedPath()
        }
        .onChange(of: selectedChannelType) { _, _ in
            selectedChannelNum = 1
            selectedDestType = mixerConfig.channelTargets(operation, source: selectedChannelType).first!
            updateResolvedPath()
        }.onChange(of: selectedChannelNum) { _, _ in
            updateResolvedPath()
        }.onChange(of: selectedDestType) { _, _ in
            selectedDestNum = 1
            updateResolvedPath()
        }
        .onChange(of: selectedDestNum) { _, _ in
            selectedValue = 0
            updateResolvedPath()
        }
        .onChange(of: selectedValue) { _, _ in
            updateResolvedPath()
        }
    }

    /**
     Source Channel Type Picker
     */
    func channelTypePicker() -> some View {
        Picker("Source Type", selection: $selectedChannelType) {
            ForEach(mixerConfig.channelsFor(operation)) { endpoint in
                Text(endpoint.rawValue)
            }
        }
        .pickerStyle(.segmented)
    }

    /**
     Source Channel Number Picker
     */
    func channelNumPicker() -> some View {
        Picker("Source Num", selection: $selectedChannelNum) {
            ForEach(Array(1 ... mixerConfig.channelCount(selectedChannelType)!), id: \.self) {
                Text("\($0)")
            }
        }
        .pickerStyle(.menu)
    }

    /**
     Destination Channel Type Picker
     */
    func destTypePicker() -> some View {
        Picker("Dest Type", selection: $selectedDestType) {
            ForEach(mixerConfig.channelTargets(operation, source: selectedChannelType)) {
                Text(verbatim: "\($0)")
            }
        }
        .pickerStyle(.segmented)
    }

    /**
     Destinateion Channel Number Picker
     */
    func destNumPicker() -> some View {
        Picker("Dest Num", selection: $selectedDestNum) {
            ForEach(Array(1 ... mixerConfig.channelCount(selectedDestType)!), id: \.self) {
                Text("\($0)")
            }
        }
        .pickerStyle(.menu)
    }

    /**
     Value Picker
     */
    func sendValueSlider() -> some View {
        Slider(value: $selectedValue, in: operation.valueRange) {
            Text("Value")
        } minimumValueLabel: {
            Text("\(Int(operation.valueRange.lowerBound))\(operation.units)")
        } maximumValueLabel: {
            Text("\(Int(operation.valueRange.upperBound))\(operation.units)")
        }
    }

    /**
     Update the resolvedPath when any of the picker values changes
     */
    func updateResolvedPath() {
        var dest = "\(selectedDestType)/\(selectedDestNum)"
        if mixerConfig.channelCount(selectedDestType)! == 1 {
            dest = "\(selectedDestType)"
        }
        let pathValues = [
            "chNum": "\(selectedChannelNum)",
            "dest": dest
        ]
        resolvedPath = dictionary.resolvePath(operation: operation,
                                              endpoint: selectedChannelType,
                                              pathValues: pathValues)!
            + " \(Int(selectedValue))"
    }
}

#Preview {
    @Previewable @State var resolvedPath = ""
    ChannelToChannelValueRangeBuilderView(operation: .pan, dictionary: SqMixerEndpointDictionary(), resolvedPath: $resolvedPath)
}
