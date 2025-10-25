//
//  SqMixerEndpoints.swift
//  sqOSC
//
//  Created by H Allen Adams on 7/5/24.
//

import Foundation
import OSCKit

/**
 Bind the OSC message addresses defined by a SqMixerEndpointDictionary to an
 OSCAddressSpace, providing for each OSC address an OSC Message handler function
 to create and publish the corresponding MIDI message.
 */
class SqOscEndpointRegistrar {
    private var addressSpace: OSCAddressSpace?
    private let dictionary: SqMixerEndpointDictionary
    private let mixerConfig: MixerConfig
    private let preferences: MixerPreferences
    private let mixerMessages: MixerMidiMessageFactory
    private let publisher: MessagePublisher

    init(dictionary: SqMixerEndpointDictionary,
         preferences: MixerPreferences,
         publisher: @escaping MessagePublisher)
    {
        self.preferences = preferences
        self.dictionary = dictionary
        self.publisher = publisher
        self.mixerConfig = dictionary.mixerConfig
        self.mixerMessages = MixerMidiMessageFactory(mixerConfig: dictionary.mixerConfig,
                                                     faderLaw: mixerConfig.faderLaws().first!)
    }

    /**
     Register endpoint dictionary entries with the given OSCAddressSpace.
     */
    func populate(addressSpace: OSCAddressSpace) {
        self.addressSpace = addressSpace

        // Register Scene and SoftKey operations
        populateSceneRecall()
        populateSoftKeys()

        // Register Audio Channel Operations
        MixerEndpoint.audioCases.forEach(populateAudioChannels)
    }

    /**
     Register all the possible OSC message addresses for a type of Audio
     Channel. Depending on the type, Audio Channel messages can include balance,
     level, mute, pan, and sendLevel methods.
     */
    private func populateAudioChannels(_ channelType: MixerEndpoint) {
        guard let channelCount = mixerConfig.channelCount(channelType) else { return }
        // Loop across each possible channel in the channel type, numbered 1 to n
        for chNum in 1 ... channelCount {
            // All audio channels support mute, so register a mute operation for
            // this channel
            populateMute(channelType, chNum)

            // Register a balence operation for this channel, if it is supported
            if mixerConfig.channelSupports(.balance, channelType) {
                populateOutputBalance(channelType, chNum)
            }

            // Register a level operation for this channel, if it is supported
            if mixerConfig.channelSupports(.level, channelType) {
                populateOutputLevel(channelType, chNum)
            }

            // Register assign, sendLevel, and pan messages as appropriate
            populateChannelToChannelMessage(.assign, channelType, chNum,
                                            populator: populateMixAssignment)
            populateChannelToChannelMessage(.pan, channelType, chNum,
                                            populator: populateSendPan)
            populateChannelToChannelMessage(.sendLevel, channelType, chNum,
                                            populator: populateSendLevel)
        }
    }

    private func populateChannelToChannelMessage(_ operation: MixerMethod,
                                                 _ sourceType: MixerEndpoint,
                                                 _ sourceNum: Int,
                                                 populator: (_: MixerEndpoint,
                                                             _: Int,
                                                             _: MixerEndpoint,
                                                             _: Int) -> Void)
    {
        if mixerConfig.channelSupports(.sendLevel, sourceType) {
            // For each possible destination type which can recieve audio
            // from the current channel
            for destType in mixerConfig.channelTargets(.sendLevel,
                                                       source: sourceType)
            {
                // Register a sendLevel operation from the current channel
                // to each possible destination channel
                let destTypeCount = mixerConfig.channelCount(destType)!
                for destChannel in 1 ... destTypeCount {
                    populator(sourceType, sourceNum, destType, destChannel)
                }
            }
        }
    }

    /**
     Register the Mix Assignment OSC Method for the source/dest channel pair.
     The Method argument will be a string with a value of "ON" or "OFF". The
     message handling closure will decode the argument and use the
     SqMixerMessages.assignMessage method to publish a MIDI message to the
     mixer.
     */
    private func populateMixAssignment(_ sourceType: MixerEndpoint,
                                       _ sourceNum: Int,
                                       _ destType: MixerEndpoint,
                                       _ destNum: Int)
    {
        let templateValues = [
            "chNum": "\(sourceNum)",
            "dest": destFor(destType, destNum)
        ]
        if let oscAddress =
            dictionary.resolveOscAddress(method: MixerMethod.assign,
                                         endpoint: sourceType,
                                         templateValues: templateValues)
        {
            addressSpace?.register(localAddress: oscAddress) { values, _, _ in
                guard let action = try? SqToggleAction(rawValue: values.masked(String.self)) else { return }
                if let midiMessage = self.mixerMessages
                    .assignMessage(midiChannel: self.preferences.midiChannel,
                                   sourceType: sourceType,
                                   sourceChannel: sourceNum,
                                   destType: destType,
                                   destChannel: destNum,
                                   action: action)
                {
                    await self.publisher("\(oscAddress) \(values)", midiMessage)
                }
            }
        }
    }

    /**
     Register the Output Balance OSC Method for the given channel. The Method
     argument will be an integer in the range -100 (balance full left) to 100
     (balance full right). The message handling closure will decode the
     argument and use the SqMixerMessages.outputBalanceMessage method to publish
     a MIDI message to the mixer.
     */
    private func populateOutputBalance(_ channelType: MixerEndpoint,
                                       _ channelNum: Int)
    {
        let templateValues = ["chNum": "\(channelNum)"]
        if let oscAddress =
            dictionary.resolveOscAddress(method: MixerMethod.balance,
                                         endpoint: channelType,
                                         templateValues: templateValues)
        {
            addressSpace?.register(localAddress: oscAddress) { values, _, _ in
                guard let panLevel = try? values.masked(Int.self) else { return }
                if let midiMessage = self.mixerMessages
                    .outputBalanceMessage(midiChannel: self.preferences.midiChannel,
                                          outputType: channelType,
                                          outputChannel: channelNum,
                                          panLevel: panLevel)
                {
                    await self.publisher("\(oscAddress) \(values)", midiMessage)
                }
            }
        }
    }

    /**
     Register the Output Level OSC Method for the given channel. The Method
     argument will be an integer in the range -100 to 10 dB. The message
     handling closure will decode the argument and use the
     SqMixerMessages.outputLevelMessage method to publish a MIDI message to the
     mixer.
     */
    private func populateOutputLevel(_ channelType: MixerEndpoint,
                                     _ channelNum: Int)
    {
        let templateValues = ["chNum": "\(channelNum)"]
        if let oscAddress =
            dictionary.resolveOscAddress(method: MixerMethod.level,
                                         endpoint: channelType,
                                         templateValues: templateValues)
        {
            addressSpace?.register(localAddress: oscAddress) { values, _, _ in
                guard let dbLevel = try? values.masked(Int.self) else { return }
                if let midiMessage = self.mixerMessages
                    .outputLevelMessage(midiChannel: self.preferences.midiChannel,
                                        outputType: channelType,
                                        outputChannel: channelNum,
                                        dbLevel: dbLevel)
                {
                    await self.publisher("\(oscAddress) \(values)", midiMessage)
                }
            }
        }
    }

    /**
     Register the Mute OSC Method for the given channel. The Method
     argument will be a string with a value of "ON" or "OFF". The message
     handling closure will decode the argument and use the
     SqMixerMessages.muteMessage method to publish a MIDI message to the
     mixer.
     */
    private func populateMute(_ channelType: MixerEndpoint,
                              _ channelNum: Int)
    {
        let templateValues = ["chNum": "\(channelNum)"]
        if let oscAddress =
            dictionary.resolveOscAddress(method: MixerMethod.mute,
                                         endpoint: channelType,
                                         templateValues: templateValues)
        {
            addressSpace?.register(localAddress: oscAddress) { values, _, _ in
                guard let action = try? SqToggleAction(rawValue: values.masked(String.self)) else { return }
                if let midiMessage = self.mixerMessages
                    .muteMessage(midiChannel: self.preferences.midiChannel,
                                 type: channelType,
                                 channel: channelNum,
                                 action: action)
                {
                    await self.publisher("\(oscAddress) \(values)", midiMessage)
                }
            }
        }
    }

    /**
     Register the Scene Recall OSC Method for each supported scene. The message
     handling closure call the SqMixerMessages.sceneRecallMessage method to
     publish a MIDI message to the mixer.
     */
    private func populateSceneRecall() {
        for scene in 1 ... mixerConfig.channelCount(MixerEndpoint.scene)! {
            let oscAddress =
                dictionary.resolveOscAddress(method: MixerMethod.recall,
                                             endpoint: MixerEndpoint.scene,
                                             templateValues: ["sceneNum": "\(scene)"])!
            addressSpace?.register(localAddress: oscAddress) { values, _, _ in
                if let midiMessage = self.mixerMessages
                    .sceneRecallMessage(midiChannel: self.preferences.midiChannel,
                                        scene: scene)
                {
                    await self.publisher("\(oscAddress) \(values)", midiMessage)
                }
            }
        }
    }

    /**
     Register the Send Level OSC Method for the source/dest channel pair. The
     Method argument will be an integer in the range -100 to 10 dB. The message
     handling closure will decode the argument and use the
     SqMixerMessages.sendLevelMessage method to publish a MIDI message to the
     mixer.
     */
    private func populateSendLevel(_ sourceType: MixerEndpoint,
                                   _ sourceNum: Int,
                                   _ destType: MixerEndpoint,
                                   _ destNum: Int)
    {
        let templateValues = [
            "chNum": "\(sourceNum)",
            "dest": destFor(destType, destNum)
        ]
        if let oscAddress =
            dictionary.resolveOscAddress(method: MixerMethod.sendLevel,
                                         endpoint: sourceType,
                                         templateValues: templateValues)
        {
            addressSpace?.register(localAddress: oscAddress) { values, _, _ in
                guard let dbLevel = try? values.masked(Int.self) else { return }
                if let midiMessage = self.mixerMessages
                    .sendLevelMessage(midiChannel: self.preferences.midiChannel,
                                      sourceType: sourceType,
                                      sourceChannel: sourceNum,
                                      destType: destType,
                                      destChannel: destNum,
                                      dbLevel: dbLevel)
                {
                    await self.publisher("\(oscAddress) \(values)", midiMessage)
                }
            }
        }
    }

    /**
     Register the Send Pan OSC Method for the given source/dest channel pair.
     The Method argument will be an integer in the range -100 (pan full left)
     to 100 (pan full right). The message handling closure will decode the
     argument and use the SqMixerMessages.outputBalanceMessage method to publish
     a MIDI message to the mixer.
     */
    private func populateSendPan(_ sourceType: MixerEndpoint,
                                 _ sourceNum: Int,
                                 _ destType: MixerEndpoint,
                                 _ destNum: Int)
    {
        let channelPathValues = [
            "chNum": "\(sourceNum)",
            "dest": destFor(destType, destNum)
        ]
        if let channelLevelPath =
            dictionary.resolveOscAddress(method: MixerMethod.pan,
                                         endpoint: sourceType,
                                         templateValues: channelPathValues)
        {
            addressSpace?.register(localAddress: channelLevelPath) { values, _, _ in
                guard let panLevel = try? values.masked(Int.self) else { return }
                if let midiMessage = self.mixerMessages
                    .sendPanMessage(midiChannel: self.preferences.midiChannel,
                                    sourceType: sourceType,
                                    sourceChannel: sourceNum,
                                    destType: destType,
                                    destChannel: destNum,
                                    panLevel: panLevel)
                {
                    await self.publisher("\(channelLevelPath) \(values)", midiMessage)
                }
            }
        }
    }

    /**
     Register the Soft Keys OSC Method (single address). The Method argument
     will be a String with value "PRESS" or "RELEASE". The message handling
     closure will decode the argument and use the SqMixerMessages.softKeyMessage
     method to publish a MIDI message to the mixer.
     */
    private func populateSoftKeys() {
        for button in 1 ... mixerConfig.channelCount(MixerEndpoint.keys)! {
            let address = dictionary.resolveOscAddress(method: MixerMethod.trigger,
                                                       endpoint: MixerEndpoint.keys,
                                                       templateValues: ["keyNum": "\(button)"])!
            addressSpace?.register(localAddress: address) { values, _, _ in
                guard let action = try? SqButtonState(rawValue: values.masked(String.self)) else { return }
                if let midiMessage = self.mixerMessages
                    .softKeyMessage(midiChannel: self.preferences.midiChannel,
                                    button: button,
                                    state: action)
                {
                    await self.publisher("\(address) \(values)", midiMessage)
                }
            }
        }
    }

    /**
     Derive the "dest" template value for the given dest channel. Destination
     types with more than one channel append the channel number to the dest
     component. Channel types with a single channel (like main) do NOT append
     the channel number.
     */
    private func destFor(_ destType: MixerEndpoint, _ destChannel: Int) -> String {
        let destTypeCount = mixerConfig.channelCount(destType)
        var dest = "\(destType)/\(destChannel)"
        if destTypeCount == 1 {
            dest = "\(destType)"
        }
        return dest
    }
}
