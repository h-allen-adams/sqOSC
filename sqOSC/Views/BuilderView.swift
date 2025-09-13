//
//  BuilderView.swift
//  sqOSC
//
//  Created by H Allen Adams on 9/12/25.
//

import SwiftUI

struct BuilderView: View {
    let dictionary: SqMixerEndpointDictionary

    @State private var selectedOperation: EndpointOperationType = .mute
    @State private var selectedTarget: EndpointType = .aux
    @State private var resolvedPath: String = ""

    var body: some View {
        VStack(alignment: .leading) {
            Section(header: Text("Selections").font(.title2)) {
                Picker("Operation", selection: $selectedOperation) {
                    ForEach(EndpointOperationType.allCases) { entry in
                        Text("\(entry.title)")
                    }
                }
                switch selectedOperation {
                case .mute:
                    MuteBuilderView(dictionary: dictionary, resolvedPath: $resolvedPath)
                case .sendLevel:
                    SendLevelBuilderView(dictionary: dictionary, resolvedPath: $resolvedPath)
                case .pan:
                    SendPanBuilderView(dictionary: dictionary, resolvedPath: $resolvedPath)
                case .level:
                    OutputLevelBuilderView(dictionary: dictionary, resolvedPath: $resolvedPath)
                case .balance:
                    OutputBalanceBuilderView(dictionary: dictionary, resolvedPath: $resolvedPath)
                case .trigger:
                    SoftkeyBuilderView(dictionary: dictionary, resolvedPath: $resolvedPath)
                case .recall:
                    SceneRecallBuilderView(dictionary: dictionary, resolvedPath: $resolvedPath)
                }
            }
            Section(header: Text("OSC Message").font(.title2)) {
                OSCMessageView(resolvedPath: $resolvedPath)
            }
            Spacer()
        }
    }
}

#Preview {
    BuilderView(dictionary: SqMixerEndpointDictionary())
}
