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
    private let mixerConfig: SqMixerConfig
    private let mixerMessages = SqMixerMessages()
    private var addressSpace: OSCAddressSpace?
    private var publisher: MessagePublisher?

    init(mixerConfig: SqMixerConfig) {
        self.mixerConfig = mixerConfig
    }

    func register(addressSpace: OSCAddressSpace?, publisher: @escaping MessagePublisher) {
        self.addressSpace = addressSpace
        self.publisher = publisher

        registerSceneRecall()
        registerSoftKeys()
        registerAudioChannels(EndpointType.input, mixerConfig.numInput)
        registerAudioChannels(EndpointType.main, mixerConfig.numMain)
        registerAudioChannels(EndpointType.aux, mixerConfig.numAux)
        registerAudioChannels(EndpointType.group, mixerConfig.numGroup)
        registerAudioChannels(EndpointType.fxSend, mixerConfig.numfxSend)
        registerAudioChannels(EndpointType.fxReturn, mixerConfig.numfxReturn)
        registerAudioChannels(EndpointType.matrix, mixerConfig.numMatrix)
        registerAudioChannels(EndpointType.dca, mixerConfig.numDca)
        registerAudioChannels(EndpointType.muteGroup, mixerConfig.numMuteGroup)
    }

    private func registerAudioChannels(_ channelType: EndpointType, _ numChannels: Int) {
        for c in 1 ... numChannels {
            let channelPathValues = ["chNum": "\(c)"]
            registerMute(channelType, c, dictionary.resolvePath(entryType: EndpointOperationType.mute, pathType: channelType, pathValues: channelPathValues)!)
            if channelType.isOutputLevel() {
                registerOutputLevel(channelType, c, dictionary.resolvePath(entryType: EndpointOperationType.level, pathType: channelType, pathValues: channelPathValues)!)
            }
            if channelType.hasSends() {
                registerSendLevel(channelType, c, dictionary.resolvePath(entryType: EndpointOperationType.sendLevel, pathType: channelType, pathValues: channelPathValues)!)
            }
        }
    }

    private func registerOutputLevel(_ channelType: EndpointType, _ channelNum: Int, _ channelLevelPath: String) {
        addressSpace?.register(localAddress: channelLevelPath) { values in
            guard let dbLevel = try? values.masked(Int.self) else { return }
            if let midiMessage = self.mixerMessages.outputLevelMessage(midiChannel: self.mixerConfig.midiChannel,
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
            if let midiMessage = self.mixerMessages.muteMessage(midiChannel: self.mixerConfig.midiChannel, type: channelType, channel: channelNum, action: action) {
                self.publisher!("\(channelMutePath) \(values)", midiMessage)
            }
        }
    }

    private func registerSceneRecall() {
        let dictionaryPath = dictionary.resolvePath(entryType: EndpointOperationType.recall, pathType: EndpointType.scene)!
        addressSpace?.register(localAddress: dictionaryPath) { values in
            guard let scene = try? values.masked(Int.self) else { return }
            if let midiMessage = self.mixerMessages.sceneRecallMessage(midiChannel: self.mixerConfig.midiChannel, scene: scene) {
                self.publisher!("\(dictionaryPath) \(values)", midiMessage)
            }
        }
    }

    private func registerSendLevel(_ channelType: EndpointType, _ channelNum: Int, _ channelLevelPath: String) {
        addressSpace?.register(localAddress: channelLevelPath) { values in
            guard let (destTypeStr, destChannel, dbLevel) = try? values.masked(String.self, Int.self, Int.self) else { return }
            guard let destType = EndpointType(rawValue: destTypeStr) else { return }
            if let midiMessage = self.mixerMessages.sendLevelMessage(midiChannel: self.mixerConfig.midiChannel,
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
        for button in 1 ... mixerConfig.numSoftKeys {
            let address = dictionary.resolvePath(entryType: EndpointOperationType.trigger,
                                                 pathType: EndpointType.keys,
                                                 pathValues: ["keyNum": "\(button)"])!
            addressSpace?.register(localAddress: address) { values in
                guard let action = try? SqButtonState(rawValue: values.masked(String.self)) else { return }
                if let midiMessage = self.mixerMessages.softKeyMessage(midiChannel: self.mixerConfig.midiChannel, button: button, state: action) {
                    self.publisher!("\(address) \(values)", midiMessage)
                }
            }
        }
    }
}
