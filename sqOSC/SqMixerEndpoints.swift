//
//  SqMixerEndpoints.swift
//  sqOSC
//
//  Created by H Allen Adams on 7/5/24.
//

import Foundation
import OSCKit

class SqMixerEndpoints {
    private let mixerConfig: SqMixerConfig
    private let mixerMessages = SqMixerMessages()
    private var addressSpace: OSCAddressSpace?
    private var dictionary: EndpointDictionary?
    private var publisher: MessagePublisher?

    init(mixerConfig: SqMixerConfig) {
        self.mixerConfig = mixerConfig
    }

    func register(addressSpace: OSCAddressSpace?, dictionary: EndpointDictionary, publisher: @escaping MessagePublisher) {
        self.addressSpace = addressSpace
        self.dictionary = dictionary
        self.publisher = publisher

        registerSceneRecall()
        registerSoftKeys()
        registerAudioChannels(SqChannelType.input, mixerConfig.numInput)
        registerAudioChannels(SqChannelType.main, mixerConfig.numMain)
        registerAudioChannels(SqChannelType.aux, mixerConfig.numAux)
        registerAudioChannels(SqChannelType.group, mixerConfig.numGroup)
        registerAudioChannels(SqChannelType.fxSend, mixerConfig.numfxSend)
        registerAudioChannels(SqChannelType.fxReturn, mixerConfig.numfxReturn)
        registerAudioChannels(SqChannelType.matrix, mixerConfig.numMatrix)
        registerAudioChannels(SqChannelType.dca, mixerConfig.numDca)
        registerAudioChannels(SqChannelType.muteGroup, mixerConfig.numMuteGroup)
    }

    private func registerAudioChannels(_ channelType: SqChannelType, _ numChannels: Int) {
        for c in 1 ... numChannels {
            let channelPathValues = ["chNum": "\(c)"]
            registerMute(channelType, c, dictionary!.resolvePath(entryType: EndpointDictEntryType.mute, pathType: channelType, pathValues: channelPathValues)!)
            if channelType.isOutputLevel() {
                registerOutputLevel(channelType, c, dictionary!.resolvePath(entryType: EndpointDictEntryType.level, pathType: channelType, pathValues: channelPathValues)!)
            }
            if channelType.hasSends() {
                registerSendLevel(channelType, c, dictionary!.resolvePath(entryType: EndpointDictEntryType.sendLevel, pathType: channelType, pathValues: channelPathValues)!)
            }
        }
    }

    private func registerOutputLevel(_ channelType: SqChannelType, _ channelNum: Int, _ channelLevelPath: String) {
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

    private func registerMute(_ channelType: SqChannelType, _ channelNum: Int, _ channelMutePath: String) {
        addressSpace?.register(localAddress: channelMutePath) { values in
            guard let action = try? SqMuteAction(rawValue: values.masked(String.self)) else { return }
            if let midiMessage = self.mixerMessages.muteMessage(midiChannel: self.mixerConfig.midiChannel, type: channelType, channel: channelNum, action: action) {
                self.publisher!("\(channelMutePath) \(values)", midiMessage)
            }
        }
    }

    private func registerSceneRecall() {
        let dictionaryPath = dictionary!.resolvePath(entryType: EndpointDictEntryType.scene)!
        addressSpace?.register(localAddress: dictionaryPath) { values in
            guard let scene = try? values.masked(Int.self) else { return }
            if let midiMessage = self.mixerMessages.sceneRecallMessage(midiChannel: self.mixerConfig.midiChannel, scene: scene) {
                self.publisher!("\(dictionaryPath) \(values)", midiMessage)
            }
        }
    }

    private func registerSendLevel(_ channelType: SqChannelType, _ channelNum: Int, _ channelLevelPath: String) {
        addressSpace?.register(localAddress: channelLevelPath) { values in
            guard let (destTypeStr, destChannel, dbLevel) = try? values.masked(String.self, Int.self, Int.self) else { return }
            guard let destType = SqChannelType(rawValue: destTypeStr) else { return }
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
            let address = dictionary!.resolvePath(entryType: EndpointDictEntryType.keys, pathValues: ["keyNum": "\(button)"])!
            addressSpace?.register(localAddress: address) { values in
                guard let action = try? SqButtonState(rawValue: values.masked(String.self)) else { return }
                if let midiMessage = self.mixerMessages.softKeyMessage(midiChannel: self.mixerConfig.midiChannel, button: button, state: action) {
                    self.publisher!("\(address) \(values)", midiMessage)
                }
            }
        }
    }
}
