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
    @Binding var resolvedEvent: AttributedString
    @Preference(\.midiChannel) var midiChannel
    @State private var selectedChannelType: MixerConfig.BuilderChannelType
    @State private var selectedChannel: MixerConfig.BuilderChannel
    @State private var selectedDestType: MixerConfig.BuilderChannelType
    @State private var selectedDest: MixerConfig.BuilderChannel
    @State private var selectedToggle: SqToggleAction = .ON

    init(dictionary: SqMixerEndpointDictionary,
         resolvedMessage: Binding<String>,
         resolvedEvent: Binding<AttributedString>)
    {
        let mixerConfig = dictionary.mixerConfig
        let method = MixerMethod.assign
        self.mixerConfig = mixerConfig
        self.method = method
        self.dictionary = dictionary
        self._resolvedMessage = resolvedMessage
        self._resolvedEvent = resolvedEvent
        
        let source = mixerConfig.builderChannelTypeFor(method).first ?? .input
        self.selectedChannelType = source
        self.selectedChannel = mixerConfig.builderChannels(source).first ?? MixerConfig.BuilderChannel.UNRESOLVED

        let dest = mixerConfig.builderChannelTargets(method, source: source).first!
        self.selectedDestType = dest
        self.selectedDest = mixerConfig.builderChannels(dest).first ?? MixerConfig.BuilderChannel.UNRESOLVED
    }
    
    var body: some View {
        VStack {
            sourcePicker()
            destPicker()
            valueToggle()
        }
        .onAppear {
            updateResolvedMessage()
        }
        .onChange(of: selectedChannelType) { _, _ in
            selectedChannel = mixerConfig.builderChannels(selectedChannelType).first!
            selectedDestType = mixerConfig.builderChannelTargets(method, source: selectedChannelType).first!
            selectedDest = mixerConfig.builderChannels(selectedDestType).first!
            updateResolvedMessage()
        }.onChange(of: selectedChannel) { _, _ in
            updateResolvedMessage()
        }.onChange(of: selectedDestType) { _, _ in
            selectedDest = mixerConfig.builderChannels(selectedDestType).first!
            updateResolvedMessage()
        }
        .onChange(of: selectedDest) { _, _ in
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
    func sourcePicker() -> some View {
        HStack {
            Text("Source")
            Picker("", selection: $selectedChannelType) {
                ForEach(mixerConfig.builderChannelTypeFor(method)) { channelType in
                    Text(channelType.title)
                }
            }
            .labelsHidden()
            Picker("", selection: $selectedChannel) {
                ForEach(mixerConfig.builderChannels(selectedChannelType), id: \.self) {
                    Text("\($0.title)")
                }
            }
            .labelsHidden()
        }
    }
        
    /**
     Destination Channel Type Picker
     */
    func destPicker() -> some View {
        HStack {
            Text("Dest")
            Picker("Dest", selection: $selectedDestType) {
                ForEach(mixerConfig.builderChannelTargets(method, source: selectedChannelType)) { channelType in
                    Text(channelType.title)
                }
            }
            .labelsHidden()
            Picker("", selection: $selectedDest) {
                ForEach(mixerConfig.builderChannels(selectedDestType), id: \.self) {
                    Text("\($0.title)")
                }
            }
            .labelsHidden()
        }
    }
        
    /**
     Value Picker
     */
    func valueToggle() -> some View {
        HStack {
            Text("Assign")
            Picker("", selection: $selectedToggle) {
                ForEach(SqToggleAction.allCases, id: \.self) {
                    Text("\(String(describing: $0))")
                }
            }
            .pickerStyle(.segmented)
            .labelsHidden()
        }
    }
    
    /**
     Update the resolvedPath when any of the picker values changes
     */
    func updateResolvedMessage() {
        var dest = "\(selectedDest.endpoint)/\(selectedDest.chNum)"
        if mixerConfig.channelCount(selectedDest.endpoint)! == 1 {
            dest = "\(selectedDest.endpoint)"
        }
        let pathValues = [
            "chNum": "\(selectedChannel.chNum)",
            "dest": dest
        ]

        let address = dictionary.resolveOscAddress(method: method,
                                                   endpoint: selectedChannel.endpoint,
                                                   templateValues: pathValues) ?? "/none"
        resolvedMessage = address + " \(selectedToggle)"
        
        guard let mixerMessages = dictionary.mixerMessages else { return }
        let event = mixerMessages.assignMessage(midiChannel: midiChannel,
                                                sourceType: selectedChannel.endpoint,
                                                sourceChannel: selectedChannel.chNum,
                                                destType: selectedDest.endpoint,
                                                destChannel: selectedDest.chNum,
                                                action: selectedToggle)
        resolvedEvent = AttributedString(MidiMessagePublisher.toString(event))
        MidiMessageViewUtilities.colorizeNrpn(&resolvedEvent)
    }
}

#Preview {
    @Previewable @State var resolvedMessage = ""
    @Previewable @State var resolvedEvent = AttributedString("")
    MixAssignmentBuilderView(dictionary: SqMixerEndpointDictionary.forConfiguration(.qu),
                             resolvedMessage: $resolvedMessage,
                             resolvedEvent: $resolvedEvent)
}
