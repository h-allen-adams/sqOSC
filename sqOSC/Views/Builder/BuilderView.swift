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
                    ChannelToChannelValueRangeBuilderView(operation: .sendLevel, dictionary: dictionary, resolvedPath: $resolvedPath)
                case .pan:
                    ChannelToChannelValueRangeBuilderView(operation: .pan, dictionary: dictionary, resolvedPath: $resolvedPath)
                case .level:
                    ChannelValueRangeBuilderView(operation: .level, dictionary: dictionary, resolvedPath: $resolvedPath)
                case .balance:
                    ChannelValueRangeBuilderView(operation: .balance, dictionary: dictionary, resolvedPath: $resolvedPath)
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
        }.padding(.all)
    }
}

#Preview {
    BuilderView(dictionary: SqMixerEndpointDictionary())
}
