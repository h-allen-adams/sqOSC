//
//  MuteBuilderView.swift
//  sqOSC
//
//  Created by H Allen Adams on 9/12/25.
//

import SwiftUI

struct SoftkeyBuilderView: View {
    let mixerConfig: SqMixerConfig
    let dictionary: SqMixerEndpointDictionary
    let operation: EndpointOperationType

    @Binding var resolvedPath: String
    @State private var selectedChannelType: EndpointType
    @State private var selectedChannelNum: Int = 1
    @State private var selectedToggle: String = "PRESS"

    init(dictionary: SqMixerEndpointDictionary, resolvedPath: Binding<String>) {
        let mixerConfig = SqMixerConfig.singletonInstance()
        let operation = EndpointOperationType.trigger
        self.dictionary = dictionary
        self.operation = operation
        self.mixerConfig = mixerConfig
        self._resolvedPath = resolvedPath
        self.selectedChannelType = mixerConfig.channelsFor(operation).first!
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
            "keyNum": "\(selectedChannelNum)"
        ]
        resolvedPath = dictionary.resolvePath(operation: operation, endpoint: selectedChannelType, pathValues: pathValues)!
            + " \(selectedToggle)"
    }
}

#Preview {
    @Previewable @State var resolvedPath = ""
    SoftkeyBuilderView(dictionary: SqMixerEndpointDictionary(), resolvedPath: $resolvedPath)
}
