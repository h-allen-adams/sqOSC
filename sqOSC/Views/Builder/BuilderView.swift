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
    @State private var resolvedEvent: AttributedString = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Each view populates the resolvedPath, which is displayed by its
            // own view which provides controls for copying or sending the
            // message
            VStack(alignment: .leading) {
                Section(header: Text("OSC Message").font(.title)) {
                    OSCMessageView(resolvedMessage: $resolvedMessage,
                                   resolvedEvent: $resolvedEvent)
                }
            }
            Section(header: Text("Selections").font(.title)) {
                VStack {
                    HStack {
                        Text("Method")
                        // Select an operation...
                        Picker("", selection: $selectedMethod) {
                            ForEach(dictionary.mixerConfig.methods()) { entry in
                                Text("\(entry.title)")
                            }
                        }
                        .labelsHidden()
                    }
                    // ...and display the view containing the control options
                    // specific to that operation.
                    switch selectedMethod {
                    case .assign:
                        MixAssignmentBuilderView(dictionary: dictionary,
                                                 resolvedMessage: $resolvedMessage,
                                                 resolvedEvent: $resolvedEvent)
                    case .mute:
                        MuteBuilderView(dictionary: dictionary,
                                        resolvedMessage: $resolvedMessage,
                                        resolvedEvent: $resolvedEvent)
                    case .sendLevel:
                        ChannelToChannelValueRangeBuilderView(method: .sendLevel,
                                                              dictionary: dictionary,
                                                              resolvedMessage: $resolvedMessage,
                                                              resolvedEvent: $resolvedEvent)
                    case .pan:
                        ChannelToChannelValueRangeBuilderView(method: .pan,
                                                              dictionary: dictionary,
                                                              resolvedMessage: $resolvedMessage,
                                                              resolvedEvent: $resolvedEvent)
                    case .level:
                        ChannelValueRangeBuilderView(method: .level,
                                                     dictionary: dictionary,
                                                     resolvedMessage: $resolvedMessage,
                                                     resolvedEvent: $resolvedEvent)
                    case .balance:
                        ChannelValueRangeBuilderView(method: .balance,
                                                     dictionary: dictionary,
                                                     resolvedMessage: $resolvedMessage,
                                                     resolvedEvent: $resolvedEvent)
                    case .trigger:
                        SoftkeyBuilderView(dictionary: dictionary,
                                           resolvedMessage: $resolvedMessage,
                                           resolvedEvent: $resolvedEvent)
                    case .recall:
                        SceneRecallBuilderView(dictionary: dictionary,
                                               resolvedMessage: $resolvedMessage,
                                               resolvedEvent: $resolvedEvent)
                    }
                }
                .padding(.trailing)
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
    BuilderView(dictionary: SqMixerEndpointDictionary.forConfiguration(.sq))
}
