//
//  SqMixerEndpoints.swift
//  sqOSC
//
//  Created by H Allen Adams on 7/5/24.
//

import Foundation
import OSCKit

class SqMixerEndpoints {
    var dictionary = SqMixerEndpointDictionary()
    private let preferences: Preferences
    private let mixerMessages = SqMixerMessages()
    private var addressSpace: OSCAddressSpace?
    private var publisher: MessagePublisher?

    init(preferences: Preferences) {
        self.preferences = preferences
    }

    func register(addressSpace: OSCAddressSpace?, publisher: @escaping MessagePublisher) {
        self.addressSpace = addressSpace
        self.publisher = publisher

        registerSceneRecall()
        registerSoftKeys()
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

    private func registerAudioChannels(_ channelType: EndpointType) {
        for c in 1 ... channelType.count {
            let channelPathValues = ["chNum": "\(c)"]
            registerMute(channelType, c, dictionary.resolvePath(operation: EndpointOperationType.mute, endpoint: channelType, pathValues: channelPathValues)!)
            if channelType.isOutputLevel() {
                registerOutputLevel(channelType, c, dictionary.resolvePath(operation: EndpointOperationType.level, endpoint: channelType, pathValues: channelPathValues)!)
            }
            if channelType.hasSends() {
                registerSendLevel(channelType, c, dictionary.resolvePath(operation: EndpointOperationType.sendLevel, endpoint: channelType, pathValues: channelPathValues)!)
            }
        }
    }

    private func registerOutputLevel(_ channelType: EndpointType, _ channelNum: Int, _ channelLevelPath: String) {
        addressSpace?.register(localAddress: channelLevelPath) { values in
            guard let dbLevel = try? values.masked(Int.self) else { return }
            if let midiMessage = self.mixerMessages.outputLevelMessage(midiChannel: self.preferences.midiChannel,
                                                                       outputType: channelType,
                                                                       outputChannel: channelNum,
                                                                       dbLevel: dbLevel)
            {
                self.publisher!("\(channelLevelPath) \(values)", midiMessage)
            }
        }
    }

    private func registerMute(_ channelType: EndpointType, _ channelNum: Int, _ channelMutePath: String) {
        addressSpace?.register(localAddress: channelMutePath) { values in
            guard let action = try? SqMuteAction(rawValue: values.masked(String.self)) else { return }
            if let midiMessage = self.mixerMessages.muteMessage(midiChannel: self.preferences.midiChannel, type: channelType, channel: channelNum, action: action) {
                self.publisher!("\(channelMutePath) \(values)", midiMessage)
            }
        }
    }

    private func registerSceneRecall() {
        let dictionaryPath = dictionary.resolvePath(operation: EndpointOperationType.recall, endpoint: EndpointType.scene)!
        addressSpace?.register(localAddress: dictionaryPath) { values in
            guard let scene = try? values.masked(Int.self) else { return }
            if let midiMessage = self.mixerMessages.sceneRecallMessage(midiChannel: self.preferences.midiChannel, scene: scene) {
                self.publisher!("\(dictionaryPath) \(values)", midiMessage)
            }
        }
    }

    private func registerSendLevel(_ channelType: EndpointType, _ channelNum: Int, _ channelLevelPath: String) {
        addressSpace?.register(localAddress: channelLevelPath) { values in
            guard let (destTypeStr, destChannel, dbLevel) = try? values.masked(String.self, Int.self, Int.self) else { return }
            guard let destType = EndpointType(rawValue: destTypeStr) else { return }
            if let midiMessage = self.mixerMessages.sendLevelMessage(midiChannel: self.preferences.midiChannel,
                                                                     sourceType: channelType,
                                                                     sourceChannel: channelNum,
                                                                     destType: destType,
                                                                     destChannel: destChannel,
                                                                     dbLevel: dbLevel)
            {
                self.publisher!("\(channelLevelPath) \(values)", midiMessage)
            }
        }
    }

    private func registerSoftKeys() {
        for button in 1 ... EndpointType.keys.count {
            let address = dictionary.resolvePath(operation: EndpointOperationType.trigger,
                                                 endpoint: EndpointType.keys,
                                                 pathValues: ["keyNum": "\(button)"])!
            addressSpace?.register(localAddress: address) { values in
                guard let action = try? SqButtonState(rawValue: values.masked(String.self)) else { return }
                if let midiMessage = self.mixerMessages.softKeyMessage(midiChannel: self.preferences.midiChannel, button: button, state: action) {
                    self.publisher!("\(address) \(values)", midiMessage)
                }
            }
        }
    }
}
