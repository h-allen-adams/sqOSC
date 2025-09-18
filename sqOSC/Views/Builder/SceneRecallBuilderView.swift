//
//  MuteBuilderView.swift
//  sqOSC
//
//  Created by H Allen Adams on 9/12/25.
//

import SwiftUI

struct SceneRecallBuilderView: View {
    let dictionary: SqMixerEndpointDictionary
    let operation: EndpointOperationType = .recall

    @Binding var resolvedPath: String
    @State private var selectedChannelType: EndpointType = EndpointOperationType.recall.endpoints.first!
    @State private var selectedSceneNum: Int = 1

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
    SceneRecallBuilderView(dictionary: SqMixerEndpointDictionary(mixerConfig: SqMixerConfig.defaultConfig()), resolvedPath: $resolvedPath)
}
