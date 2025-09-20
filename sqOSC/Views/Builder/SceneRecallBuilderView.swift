//
//  MuteBuilderView.swift
//  sqOSC
//
//  Created by H Allen Adams on 9/12/25.
//

import SwiftUI

struct SceneRecallBuilderView: View {
    let mixerConfig: SqMixerConfig
    let dictionary: SqMixerEndpointDictionary
    let operation: EndpointOperationType

    @Binding var resolvedPath: String
    @State private var selectedChannelType: EndpointType
    @State private var selectedSceneNum: Int = 1

    init(dictionary: SqMixerEndpointDictionary, resolvedPath: Binding<String>) {
        let mixerConfig = SqMixerConfig.singletonInstance()
        let operation = EndpointOperationType.recall
        self.dictionary = dictionary
        self.mixerConfig = mixerConfig
        self.operation = operation
        self._resolvedPath = resolvedPath
        self.selectedChannelType = mixerConfig.channelsFor(operation).first!
    }

    var body: some View {
        VStack {
            HStack {
                Picker("Scene Num", selection: $selectedSceneNum) {
                    ForEach(Array(1 ... 300), id: \.self) {
                        Text("\($0)")
                    }
                }
                .pickerStyle(.menu)
            }
        }
        .onAppear {
            updateResolvedPath()
        }
        .onChange(of: selectedChannelType) { _, _ in
            updateResolvedPath()
        }
        .onChange(of: selectedSceneNum) { _, _ in
            updateResolvedPath()
        }
    }

    func updateResolvedPath() {
        resolvedPath = dictionary.resolvePath(operation: operation, endpoint: selectedChannelType)! + " \(selectedSceneNum)"
    }
}

#Preview {
    @Previewable @State var resolvedPath = ""
    SceneRecallBuilderView(dictionary: SqMixerEndpointDictionary(), resolvedPath: $resolvedPath)
}
