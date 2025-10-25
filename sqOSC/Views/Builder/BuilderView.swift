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
    @ObservedObject var dictionary: SqMixerEndpointDictionary

    @State private var selectedMethod: MixerMethod = .mute
    @State private var selectedTarget: MixerEndpoint = .aux
    @State private var resolvedMessage: String = ""

    var body: some View {
        VStack(alignment: .leading) {
            Section(header: Text("Selections").font(.title2)) {
                // Select an operation...
                Picker("Method", selection: $selectedMethod) {
                    ForEach(dictionary.mixerConfig.methods()) { entry in
                        Text("\(entry.title)")
                    }
                }
                // ...and display the view containing the control options
                // specific to that operation.
                switch selectedMethod {
                case .assign:
                    MixAssignmentBuilderView(dictionary: dictionary,
                                             resolvedMessage: $resolvedMessage)
                case .mute:
                    MuteBuilderView(dictionary: dictionary,
                                    resolvedMessage: $resolvedMessage)
                case .sendLevel:
                    ChannelToChannelValueRangeBuilderView(method: .sendLevel,
                                                          dictionary: dictionary,
                                                          resolvedMessage: $resolvedMessage)
                case .pan:
                    ChannelToChannelValueRangeBuilderView(method: .pan,
                                                          dictionary: dictionary,
                                                          resolvedMessage: $resolvedMessage)
                case .level:
                    ChannelValueRangeBuilderView(method: .level,
                                                 dictionary: dictionary,
                                                 resolvedMessage: $resolvedMessage)
                case .balance:
                    ChannelValueRangeBuilderView(method: .balance,
                                                 dictionary: dictionary,
                                                 resolvedMessage: $resolvedMessage)
                case .trigger:
                    SoftkeyBuilderView(dictionary: dictionary,
                                       resolvedMessage: $resolvedMessage)
                case .recall:
                    SceneRecallBuilderView(dictionary: dictionary,
                                           resolvedMessage: $resolvedMessage)
                }
            }
            // Each view populates the resolvedPath, which is displayed by its
            // own view which provides controls for copying or sending the
            // message
            Section(header: Text("OSC Message").font(.title2)) {
                OSCMessageView(resolvedMessage: $resolvedMessage)
            }
            Spacer()
        }
        .onDisappear {
            selectedMethod = .mute
        }
        .padding(.all)
    }
}

#Preview {
    BuilderView(dictionary: SqMixerEndpointDictionary(.sq))
}
