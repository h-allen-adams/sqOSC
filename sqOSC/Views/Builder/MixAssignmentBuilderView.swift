//
//  MixAssignmentBuilderView.swift
//  sqOSC
//
//  Created by H Allen Adams on 10/10/25.
//

import SwiftUI

struct MixAssignmentBuilderView: View {
    let mixerConfig: MixerConfig
    let method: MixerMethod
    
    @ObservedObject var dictionary: SqMixerEndpointDictionary
    @Binding var resolvedMessage: String
    @State private var selectedChannelType: MixerEndpoint
    @State private var selectedDestType: MixerEndpoint
    @State private var selectedChannelNum: Int = 1
    @State private var selectedDestNum: Int = 1
    @State private var selectedToggle: SqToggleAction = .ON

    init(dictionary: SqMixerEndpointDictionary,
         resolvedMessage: Binding<String>)
    {
        let mixerConfig = dictionary.mixerConfig
        let method = MixerMethod.assign
        self.mixerConfig = mixerConfig
        self.method = method
        self.dictionary = dictionary
        self._resolvedMessage = resolvedMessage
        
        let source = mixerConfig.channelsFor(method).first!
        self.selectedChannelType = source
        self.selectedDestType = mixerConfig.channelTargets(method, source: source).first!
    }
    
    var body: some View {
        VStack {
            channelTypePicker()
            channelNumPicker()
            destTypePicker()
            destNumPicker()
            valueToggle()
        }
        .onAppear {
            updateResolvedMessage()
        }
        .onChange(of: selectedChannelType) { _, _ in
            selectedChannelNum = 1
            selectedDestType = mixerConfig.channelTargets(method, source: selectedChannelType).first!
            updateResolvedMessage()
        }.onChange(of: selectedChannelNum) { _, _ in
            updateResolvedMessage()
        }.onChange(of: selectedDestType) { _, _ in
            selectedDestNum = 1
            updateResolvedMessage()
        }
        .onChange(of: selectedDestNum) { _, _ in
            selectedToggle = .ON
            updateResolvedMessage()
        }
        .onChange(of: selectedToggle) { _, _ in
            updateResolvedMessage()
        }
    }
    
    /**
     Source Channel Type Picker
     */
    func channelTypePicker() -> some View {
        Picker("Source Type", selection: $selectedChannelType) {
            ForEach(mixerConfig.channelsFor(method)) { endpoint in
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
            ForEach(mixerConfig.channelTargets(method, source: selectedChannelType)) {
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
    func valueToggle() -> some View {
        Picker("Toggle", selection: $selectedToggle) {
            ForEach(SqToggleAction.allCases, id: \.self) {
                Text("\(String(describing: $0))")
            }
        }
        .pickerStyle(.segmented)
    }
    
    /**
     Update the resolvedPath when any of the picker values changes
     */
    func updateResolvedMessage() {
        var dest = "\(selectedDestType)/\(selectedDestNum)"
        if mixerConfig.channelCount(selectedDestType)! == 1 {
            dest = "\(selectedDestType)"
        }
        let pathValues = [
            "chNum": "\(selectedChannelNum)",
            "dest": dest
        ]

        let address = dictionary.resolveOscAddress(method: method,
                                                   endpoint: selectedChannelType,
                                                   templateValues: pathValues) ?? "/none"
        resolvedMessage = address + " \(selectedToggle)"
    }
}

#Preview {
    @Previewable @State var resolvedMessage = ""
    MixAssignmentBuilderView(dictionary: SqMixerEndpointDictionary(.sq),
                             resolvedMessage: $resolvedMessage)
}
