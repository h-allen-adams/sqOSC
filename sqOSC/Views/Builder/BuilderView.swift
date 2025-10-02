//
//  BuilderView.swift
//  sqOSC
//
//  Created by H Allen Adams on 9/12/25.
//

import SwiftUI

/**
 The Builder view allows the user to build up a resolved OSC message path by
 selecting operation type, channel, and other message values.
 */
struct BuilderView: View {
    let dictionary: SqMixerEndpointDictionary

    @State private var selectedOperation: EndpointOperationType = .mute
    @State private var selectedTarget: EndpointType = .aux
    @State private var resolvedPath: String = ""

    var body: some View {
        VStack(alignment: .leading) {
            Section(header: Text("Selections").font(.title2)) {
                // Select an operation...
                Picker("Operation", selection: $selectedOperation) {
                    ForEach(EndpointOperationType.allCases) { entry in
                        Text("\(entry.title)")
                    }
                }
                // ...and display the view containing the control options
                // specific to that operation.
                switch selectedOperation {
                case .mute:
                    MuteBuilderView(dictionary: dictionary,
                                    resolvedPath: $resolvedPath)
                case .sendLevel:
                    ChannelToChannelValueRangeBuilderView(operation: .sendLevel,
                                                          dictionary: dictionary,
                                                          resolvedPath: $resolvedPath)
                case .pan:
                    ChannelToChannelValueRangeBuilderView(operation: .pan,
                                                          dictionary: dictionary,
                                                          resolvedPath: $resolvedPath)
                case .level:
                    ChannelValueRangeBuilderView(operation: .level,
                                                 dictionary: dictionary,
                                                 resolvedPath: $resolvedPath)
                case .balance:
                    ChannelValueRangeBuilderView(operation: .balance,
                                                 dictionary: dictionary,
                                                 resolvedPath: $resolvedPath)
                case .trigger:
                    SoftkeyBuilderView(dictionary: dictionary,
                                       resolvedPath: $resolvedPath)
                case .recall:
                    SceneRecallBuilderView(dictionary: dictionary,
                                           resolvedPath: $resolvedPath)
                }
            }
            // Each view populates the resolvedPath, which is displayed by its
            // own view which provides controls for copying or sending the
            // message
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
