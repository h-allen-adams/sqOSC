//
//  SqMixerEndpoints.swift
//  sqOSC
//
//  Created by H Allen Adams on 7/5/24.
//

import Foundation
import OSCKit

/**
 Bind the OSC message addresses defined by a SqMixerEndpointDictionary
 to an OSCAddressSpace, providing for each OSC address an OSC Message handler
 function to create and publish the corresponding MIDI message. The algorithm
 to convert fader levels, channel numbers, and other parameters into MIDI
 messages is contained in this class.
 */
class SqOscEndpointRegistrar {
    let dictionary: SqMixerEndpointDictionary
    let mixerConfig = SqMixerConfig.singletonInstance()
    private let preferences: MidiPreferences
    private let mixerMessages: SqMixerMessages
    private var addressSpace: OSCAddressSpace?
    private var publisher: MessagePublisher?

    init(dictionary: SqMixerEndpointDictionary, preferences: MidiPreferences) {
        self.preferences = preferences
        self.dictionary = dictionary
        self.mixerMessages = SqMixerMessages()
    }

    /**
     Register endpoint dictionary entries with the given OSCAddressSpace.
     */
    func register(addressSpace: OSCAddressSpace?, publisher: @escaping MessagePublisher) {
        self.addressSpace = addressSpace
        self.publisher = publisher

        // Register Scene and SoftKey operations
        registerSceneRecall()
        registerSoftKeys()

        // Register Audio Channel Operations
        registerAudioChannels(EndpointType.input)
        registerAudioChannels(EndpointType.main)
        registerAudioChannels(EndpointType.aux)
        registerAudioChannels(EndpointType.group)
        registerAudioChannels(EndpointType.fxSend)
        registerAudioChannels(EndpointType.fxReturn)
        registerAudioChannels(EndpointType.matrix)
        registerAudioChannels(EndpointType.dca)
        registerAudioChannels(EndpointType.muteGroup)
    }

    /**
     Register all the possible OSC message addresses for a type of audio
     channel. Depending on the type, Audio channel messages can include balance,
     level, mute, pan, and sendLevel operations.
     */
    private func registerAudioChannels(_ channelType: EndpointType) {
        // Loop across each possible channel in the channel type, numbered 1 to n
        for c in 1 ... mixerConfig.channelCount(channelType)! {
            // Add a chNum substitution variable for the channel number
            let channelPathValues = ["chNum": "\(c)"]

            // All audio channels support mute, so register a mute operation for this channel
            registerMute(channelType, c,
                         dictionary.resolvePath(operation: EndpointOperationType.mute,
                                                endpoint: channelType,
                                                pathValues: channelPathValues)!)

            // Register a balence operation for this channel, if it is supported
            if mixerConfig.channelSupports(.balance, channelType) {
                registerOutputBalance(channelType, c,
                                      dictionary.resolvePath(operation: EndpointOperationType.balance,
                                                             endpoint: channelType,
                                                             pathValues: channelPathValues)!)
            }

            // Register a level operation for this channel, if it is supported
            if mixerConfig.channelSupports(.level, channelType) {
                registerOutputLevel(channelType, c,
                                    dictionary.resolvePath(operation: EndpointOperationType.level,
                                                           endpoint: channelType,
                                                           pathValues: channelPathValues)!)
            }

            // If the channel supports send levels, create a set of operations
            // for each destination channel which can receive audio from the
            // current channel
            if mixerConfig.channelSupports(.sendLevel, channelType) {

                // For each possible destination type which can recieve audio
                // from the current channel
                for destType in mixerConfig.channelTargets(.sendLevel, source: channelType) {

                    // Register a sendLevel operation from the current channel
                    // to each possible destination channel
                    let destTypeCount = mixerConfig.channelCount(destType)!
                    for destChannel in 1 ... destTypeCount {
                        var dest = "\(destType)/\(destChannel)"
                        if destTypeCount == 1 {
                            dest = "\(destType)"
                        }
                        registerSendLevel(channelType, c,
                                          destType, destChannel,
                                          dictionary.resolvePath(operation: EndpointOperationType.sendLevel,
                                                                 endpoint: channelType,
                                                                 pathValues: ["chNum": "\(c)", "dest": dest])!)

                        // Channels which support sendLevel messages may also
                        // support pan messages
                        if mixerConfig.channelTargets(.pan, source: channelType).contains(destType) {
                            registerSendPan(channelType, c,
                                            destType, destChannel,
                                            dictionary.resolvePath(operation: EndpointOperationType.pan,
                                                                   endpoint: channelType,
                                                                   pathValues: ["chNum": "\(c)", "dest": dest])!)
                        }
                    }
                }
            }
        }
    }

    private func registerOutputBalance(_ channelType: EndpointType,
                                       _ channelNum: Int,
                                       _ channelLevelPath: String) {
        
        addressSpace?.register(localAddress: channelLevelPath) { values, _, _ in
            guard let panLevel = try? values.masked(Int.self) else { return }
            if let midiMessage = self.mixerMessages.outputBalanceMessage(midiChannel: self.preferences.midiChannel,
                                                                         outputType: channelType,
                                                                         outputChannel: channelNum,
                                                                         panLevel: panLevel)
            {
                await self.publisher!("\(channelLevelPath) \(values)", midiMessage)
            }
        }
    }

    private func registerOutputLevel(_ channelType: EndpointType,
                                     _ channelNum: Int,
                                     _ channelLevelPath: String) {
        addressSpace?.register(localAddress: channelLevelPath) { values, _, _ in
            guard let dbLevel = try? values.masked(Int.self) else { return }
            if let midiMessage = self.mixerMessages.outputLevelMessage(midiChannel: self.preferences.midiChannel,
                                                                       outputType: channelType,
                                                                       outputChannel: channelNum,
                                                                       dbLevel: dbLevel)
            {
                await self.publisher!("\(channelLevelPath) \(values)", midiMessage)
            }
        }
    }

    private func registerMute(_ channelType: EndpointType,
                              _ channelNum: Int,
                              _ channelMutePath: String) {
        addressSpace?.register(localAddress: channelMutePath) { values, _, _ in
            guard let action = try? SqMuteAction(rawValue: values.masked(String.self)) else { return }
            if let midiMessage = self.mixerMessages.muteMessage(midiChannel: self.preferences.midiChannel,
                                                                type: channelType,
                                                                channel: channelNum,
                                                                action: action) {
                await self.publisher!("\(channelMutePath) \(values)", midiMessage)
            }
        }
    }

    private func registerSceneRecall() {
        let dictionaryPath = dictionary.resolvePath(operation: EndpointOperationType.recall,
                                                    endpoint: EndpointType.scene)!
        addressSpace?.register(localAddress: dictionaryPath) { values, _, _ in
            guard let scene = try? values.masked(Int.self) else { return }
            if let midiMessage = self.mixerMessages.sceneRecallMessage(midiChannel: self.preferences.midiChannel,
                                                                       scene: scene) {
                await self.publisher!("\(dictionaryPath) \(values)", midiMessage)
            }
        }
    }

    private func registerSendLevel(_ sourceType: EndpointType,
                                   _ sourceNum: Int,
                                   _ destType: EndpointType,
                                   _ destNum: Int,
                                   _ channelLevelPath: String) {
        addressSpace?.register(localAddress: channelLevelPath) { values, _, _ in
            guard let dbLevel = try? values.masked(Int.self) else { return }
            if let midiMessage = self.mixerMessages.sendLevelMessage(midiChannel: self.preferences.midiChannel,
                                                                     sourceType: sourceType,
                                                                     sourceChannel: sourceNum,
                                                                     destType: destType,
                                                                     destChannel: destNum,
                                                                     dbLevel: dbLevel)
            {
                await self.publisher!("\(channelLevelPath) \(values)", midiMessage)
            }
        }
    }

    private func registerSendPan(_ sourceType: EndpointType,
                                 _ sourceNum: Int,
                                 _ destType: EndpointType,
                                 _ destNum: Int,
                                 _ channelLevelPath: String) {
        addressSpace?.register(localAddress: channelLevelPath) { values, _, _ in
            guard let panLevel = try? values.masked(Int.self) else { return }
            if let midiMessage = self.mixerMessages.sendPanMessage(midiChannel: self.preferences.midiChannel,
                                                                   sourceType: sourceType,
                                                                   sourceChannel: sourceNum,
                                                                   destType: destType,
                                                                   destChannel: destNum,
                                                                   panLevel: panLevel)
            {
                await self.publisher!("\(channelLevelPath) \(values)", midiMessage)
            }
        }
    }

    private func registerSoftKeys() {
        for button in 1 ... mixerConfig.channelCount(EndpointType.keys)! {
            let address = dictionary.resolvePath(operation: EndpointOperationType.trigger,
                                                 endpoint: EndpointType.keys,
                                                 pathValues: ["keyNum": "\(button)"])!
            addressSpace?.register(localAddress: address) { values, _, _ in
                guard let action = try? SqButtonState(rawValue: values.masked(String.self)) else { return }
                if let midiMessage = self.mixerMessages.softKeyMessage(midiChannel: self.preferences.midiChannel,
                                                                       button: button,
                                                                       state: action) {
                    await self.publisher!("\(address) \(values)", midiMessage)
                }
            }
        }
    }
}
