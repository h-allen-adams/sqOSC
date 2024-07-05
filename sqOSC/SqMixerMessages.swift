//
//  SqMixerMessages.swift
//  sqOSC
//
//  Created by H Allen Adams on 7/5/24.
//

import Foundation

class SqMixerMessages {
    // 3.3 Mutes
    // format of SQ Mute message is BN 63 MSB BN 62 LSB BN 06 00 BN 26 ACTION
    // where N is MIDI channel (1), MSB,LSB is channel number, ACTION=01 mute, 00= unmute
    // other values are literal hex values
    // see https://www.allen-heath.com/media/SQ-MIDI-Protocol-Issue1.pdf
    private let muteParameters = [
        SqChannelType.input: Values.toParameterNumber("00", "00"),
        SqChannelType.group: Values.toParameterNumber("00", "30"),
        SqChannelType.fxReturn: Values.toParameterNumber("00", "3C"),
        SqChannelType.main: Values.toParameterNumber("00", "44"),
        SqChannelType.aux: Values.toParameterNumber("00", "45"),
        SqChannelType.fxSend: Values.toParameterNumber("00", "51"),
        SqChannelType.matrix: Values.toParameterNumber("00", "55"),
        SqChannelType.dca: Values.toParameterNumber("02", "00"),
        SqChannelType.muteGroup: Values.toParameterNumber("04", "00")
    ]
    func muteMessage(midiChannel: Int, type: SqChannelType, channel: Int, action: SqMuteAction) -> String? {
        let cb = channelByte(midiChannel)
        if let pn = muteParameters[type] {
            let (msb, lsb) = Values.toMsbLsb(pn + channel - 1)

            switch action {
            case SqMuteAction.ON:
                return "\(cb) 63 \(msb) \(cb) 62 \(lsb) \(cb) 06 00 \(cb) 26 01"
            case SqMuteAction.OFF:
                return "\(cb) 63 \(msb) \(cb) 62 \(lsb) \(cb) 06 00 \(cb) 26 00"
            case SqMuteAction.TOGGLE:
                return "\(cb) 63 \(msb) \(cb) 62 \(lsb) \(cb) 60 00"
            }
        }
        return nil
    }

    private func channelByte(_ midiChannel: Int) -> String {
        return "B\(midiChannel - 1)"
    }
}
