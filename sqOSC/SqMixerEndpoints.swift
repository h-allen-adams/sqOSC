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

    init(mixerConfig: SqMixerConfig) {
        self.mixerConfig = mixerConfig
    }

    func register(addressSpace: OSCAddressSpace, publisher: @escaping MessagePublisher) {
        for c in 1 ... mixerConfig.numInput {
            registerMute(addressSpace, publisher, SqChannelType.input, c)
        }
    }

    private func registerMute(_ addressSpace: OSCAddressSpace, _ publisher: @escaping MessagePublisher, _ channelType: SqChannelType, _ channelNum: Int) {
        var address = "/sq/\(channelType)/\(channelNum)/mute"
        if channelType == SqChannelType.main {
            address = "/sq/\(channelType)/mute"
        }
        addressSpace.register(localAddress: address) { values in
            guard let action = try? SqMuteAction(rawValue: values.masked(String.self)) else { return }
            if let midiMessage = self.mixerMessages.muteMessage(midiChannel: self.mixerConfig.midiChannel, type: channelType, channel: channelNum, action: action) {
                publisher("\(address) \(values)", midiMessage)
            }
        }
    }
}
