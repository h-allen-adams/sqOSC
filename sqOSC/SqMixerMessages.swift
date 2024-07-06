//
//  SqMixerMessages.swift
//  sqOSC
//
//  Created by H Allen Adams on 7/5/24.
//

import Foundation

class SqMixerMessages {
    // Linear adjustements are based on 16384 possible values, approx 119 values per dB
    // +10db is value 16384, so scale down from there
    func linearFader(dbLevel: Int) -> (vc: String, vf: String) {
        var workingDb = dbLevel
        if workingDb > 10 { workingDb = 10 }
        if workingDb < -89 { return ("00", "00") }
        let adjustedDB = workingDb - 10
        let delta = Int(round(Double(adjustedDB) * 118.72))
        let v = 16383 + delta
        let vc = Values.decToHex(v / 128)
        let vf = Values.decToHex(v % 128)
        return (vc, vf)
    }

    // BN 63 MB BN 62 LB BN 06 VC BN 26 VF
    private let outputParameters = [
        SqChannelType.main: Values.toParameterNumber("4F", "00"),
        SqChannelType.aux: Values.toParameterNumber("4F", "01"),
        SqChannelType.fxSend: Values.toParameterNumber("4F", "0D"),
        SqChannelType.matrix: Values.toParameterNumber("4F", "11"),
        SqChannelType.dca: Values.toParameterNumber("4F", "20")
    ]
    func outputLevelMessage(midiChannel: Int, outputType: SqChannelType, outputChannel: Int, dbLevel: Int) -> String? {
        let bn = channelByte(midiChannel)
        if let pn = outputParameters[outputType] {
            let (msb, lsb) = Values.toMsbLsb(pn + outputChannel - 1)
            let (vc, vf) = linearFader(dbLevel: dbLevel)
            return "\(bn) 63 \(msb) \(bn) 62 \(lsb) \(bn) 06 \(vc) \(bn) 26 \(vf)"
        }
        return nil
    }

    private let sendNumCols = [
        SqChannelType.main: 1,
        SqChannelType.aux: 12,
        SqChannelType.fxSend: 4,
        SqChannelType.matrix: 3
    ]
    private let sendParams = [
        SqChannelType.input: [
            SqChannelType.main: Values.toParameterNumber("40", "00"),
            SqChannelType.aux: Values.toParameterNumber("40", "44"),
            SqChannelType.fxSend: Values.toParameterNumber("4C", "14")
        ],
        SqChannelType.group: [
            SqChannelType.main: Values.toParameterNumber("40", "30"),
            SqChannelType.aux: Values.toParameterNumber("45", "04"),
            SqChannelType.fxSend: Values.toParameterNumber("4D", "54"),
            SqChannelType.matrix: Values.toParameterNumber("4E", "4B")
        ],
        SqChannelType.fxReturn: [
            SqChannelType.main: Values.toParameterNumber("40", "3C"),
            SqChannelType.aux: Values.toParameterNumber("46", "14"),
            SqChannelType.fxSend: Values.toParameterNumber("4E", "04")
        ],
        SqChannelType.main: [
            SqChannelType.matrix: Values.toParameterNumber("4E", "24")
        ],
        SqChannelType.aux: [
            SqChannelType.matrix: Values.toParameterNumber("4E", "27")
        ]
    ]
    func sendLevelMessage(midiChannel: Int, sourceType: SqChannelType, sourceChannel: Int, destType: SqChannelType, destChannel: Int, dbLevel: Int) -> String? {
        guard let numCols = sendNumCols[destType] else { return nil }
        guard let sourceParams = sendParams[sourceType] else { return nil }
        guard let pn = sourceParams[destType] else { return nil }
        let bn = channelByte(midiChannel)
        let (msb, lsb) = Values.toMsbLsb(pn + numCols * (sourceChannel - 1) + (destChannel - 1))
        let (vc, vf) = linearFader(dbLevel: dbLevel)
        return "\(bn) 63 \(msb) \(bn) 62 \(lsb) \(bn) 06 \(vc) \(bn) 26 \(vf)"
    }

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
        let bn = channelByte(midiChannel)
        if let pn = muteParameters[type] {
            let (msb, lsb) = Values.toMsbLsb(pn + channel - 1)

            switch action {
            case SqMuteAction.ON:
                return "\(bn) 63 \(msb) \(bn) 62 \(lsb) \(bn) 06 00 \(bn) 26 01"
            case SqMuteAction.OFF:
                return "\(bn) 63 \(msb) \(bn) 62 \(lsb) \(bn) 06 00 \(bn) 26 00"
            case SqMuteAction.TOGGLE:
                return "\(bn) 63 \(msb) \(bn) 62 \(lsb) \(bn) 60 00"
            }
        }
        return nil
    }

    /**
     Section 3.1 Scene Change
     A scene change uses a bank change followed by a program change.
     BN 00 BK CN PG
     Where: N= MIDI Channel, BK = Bank, PG = Program
     The bank change (BK) selects between three ranges of scenes:
     Scenes 1 to 128 = Bank 1 = 00
     Scenes 129 to 256 = Bank 2 =01
     Scenes 257 to 300 = Bank 3 =02
     */
    func sceneRecallMessage(midiChannel: Int, scene: Int) -> String? {
        let bn = channelByte(midiChannel)
        let cn = channelByte(midiChannel, flag: "C")
        let bk = Values.decToHex(scene / 128)
        let pg = Values.decToHex((scene % 128) - 1)
        return "\(bn) 00 \(bk) \(cn) \(pg)"
    }

    func softKeyMessage(midiChannel: Int, button: Int, state: SqButtonState) -> String? {
        let bnPress = channelByte(midiChannel, flag: "9")
        let bnRelease = channelByte(midiChannel, flag: "8")
        let sk = Values.decToHex(Values.hexToDec("30") + button - 1)
        switch state {
        case SqButtonState.PRESS:
            return "\(bnPress) \(sk) 7F"
        case SqButtonState.RELEASE:
            return "\(bnRelease) \(sk) 00"
        }
    }

    private func channelByte(_ midiChannel: Int, flag: String = "B") -> String {
        let hex = String(midiChannel - 1, radix: 16).uppercased()
        return "\(flag)\(hex)"
    }
}
