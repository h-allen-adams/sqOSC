//
//  SqMixerMessages.swift
//  sqOSC
//
//  Created by H Allen Adams on 7/5/24.
//

import Foundation
import MIDIKitCore
import SwiftRadix

class SqMixerMessages {
    let mixerConfig: SqMixerConfig

    init(mixerConfig: SqMixerConfig) {
        self.mixerConfig = mixerConfig
    }

    // Linear adjustments are based on 16384 possible values, approx 119 values per dB
    // +10db is value 16384, so scale down from there
    func linearFader(dbLevel: Int) -> Int {
        var workingDb = dbLevel
        if workingDb > 10 { workingDb = 10 }
        if workingDb < -89 { return 0 }
        let adjustedDB = workingDb - 10
        let delta = Int(round(Double(adjustedDB) * 118.72))
        let v = 16383 + delta
        return v
    }

    // Pan -100: 00 00, 0: 3F 7F, 100: 7F 7F
    func panValue(panLevel: Int) -> Int {
        let zero = Values.toParameterNumber("3F", "7F")
        let factor = Double(zero) / 100.0
        var workingLevel = panLevel
        if workingLevel > 100 { workingLevel = 100 }
        if workingLevel < -100 { workingLevel = -100 }
        let v = zero + Int(round(Double(workingLevel) * factor))
        return v
    }

    // BN 63 MB BN 62 LB BN 06 VC BN 26 VF
    func outputLevelMessage(midiChannel: Int, outputType: EndpointType, outputChannel: Int, dbLevel: Int) -> MIDIEvent? {
        if let pn0 = mixerConfig.channelParameter(.level, outputType) {
            let pn = pn0 + outputChannel - 1
            let pv = linearFader(dbLevel: dbLevel)
            return MIDIEvent.nrpn(parameter: UInt7Pair(msb: UInt7(pn / 128), lsb: UInt7(pn % 128)),
                                  data: (UInt7(pv / 128), UInt7(pv % 128)),
                                  channel: UInt4(midiChannel - 1))
        }
        return nil
    }

    func outputBalanceMessage(midiChannel: Int, outputType: EndpointType, outputChannel: Int, panLevel: Int) -> MIDIEvent? {
        if let pn0 = mixerConfig.channelParameter(.balance, outputType) {
            let pn = pn0 + outputChannel - 1
            let pv = panValue(panLevel: panLevel)
            return MIDIEvent.nrpn(parameter: UInt7Pair(msb: UInt7(pn / 128), lsb: UInt7(pn % 128)),
                                  data: (UInt7(pv / 128), UInt7(pv % 128)),
                                  channel: UInt4(midiChannel - 1))
        }
        return nil
    }

    func sendLevelMessage(midiChannel: Int, sourceType: EndpointType, sourceChannel: Int, destType: EndpointType, destChannel: Int, dbLevel: Int) -> MIDIEvent? {
        guard let numCols = mixerConfig.channelCount(destType) else { return nil }
        guard let pn0 = mixerConfig.channelParameter(.sendLevel, source: sourceType, dest: destType) else { return nil }
        let pn = pn0 + numCols * (sourceChannel - 1) + (destChannel - 1)
        let pv = linearFader(dbLevel: dbLevel)
        return MIDIEvent.nrpn(parameter: UInt7Pair(msb: UInt7(pn / 128), lsb: UInt7(pn % 128)),
                              data: (UInt7(pv / 128), UInt7(pv % 128)),
                              channel: UInt4(midiChannel - 1))
    }

    func sendPanMessage(midiChannel: Int, sourceType: EndpointType, sourceChannel: Int, destType: EndpointType, destChannel: Int, panLevel: Int) -> MIDIEvent? {
        guard let numCols = mixerConfig.channelCount(destType) else { return nil }
        guard let pn0 = mixerConfig.channelParameter(.pan, source: sourceType, dest: destType) else { return nil }
        let pn = pn0 + numCols * (sourceChannel - 1) + (destChannel - 1)
        let pv = panValue(panLevel: panLevel)
        return MIDIEvent.nrpn(parameter: UInt7Pair(msb: UInt7(pn / 128), lsb: UInt7(pn % 128)),
                              data: (UInt7(pv / 128), UInt7(pv % 128)),
                              channel: UInt4(midiChannel - 1))
    }

    // 3.3 Mutes
    // format of SQ Mute message is BN 63 MSB BN 62 LSB BN 06 00 BN 26 ACTION
    // where N is MIDI channel (1), MSB,LSB is channel number, ACTION=01 mute, 00= unmute
    // other values are literal hex values
    // see https://www.allen-heath.com/media/SQ-MIDI-Protocol-Issue1.pdf
    func muteMessage(midiChannel: Int, type: EndpointType, channel: Int, action: SqMuteAction) -> MIDIEvent? {
        if let pn0 = mixerConfig.channelParameter(.mute, type) {
            let pn = pn0 + channel - 1

            switch action {
            case SqMuteAction.ON:
                return MIDIEvent.nrpn(parameter: UInt7Pair(msb: UInt7(pn / 128), lsb: UInt7(pn % 128)),
                                      data: (UInt7(0), UInt7(1)),
                                      channel: UInt4(midiChannel - 1))
            case SqMuteAction.OFF:
                return MIDIEvent.nrpn(parameter: UInt7Pair(msb: UInt7(pn / 128), lsb: UInt7(pn % 128)),
                                      data: (UInt7(0), UInt7(0)),
                                      channel: UInt4(midiChannel - 1))
            case SqMuteAction.TOGGLE:
                let controller = MIDIEvent.AssignableController.raw(parameter: UInt7Pair(msb: UInt7(pn / 128), lsb: UInt7(pn % 128)),
                                                                    dataEntryMSB: UInt7("60".hex!.value),
                                                                    dataEntryLSB: nil)
                return MIDIEvent.nrpn(controller,
                                      channel: UInt4(midiChannel - 1))
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
    func sceneRecallMessage(midiChannel: Int, scene: Int) -> MIDIEvent? {
        let bk = scene / 128
        let pg = (scene % 128) - 1
        let event = MIDIEvent.programChange(program: UInt7(pg),
                                            bank: MIDIEvent.ProgramChange.Bank.bankSelect(UInt14(bk)),
                                            channel: UInt4(midiChannel) - 1)
        return event
    }

    func softKeyMessage(midiChannel: Int, button: Int, state: SqButtonState) -> MIDIEvent? {
        let sk = Values.hexToDec("30") + button - 1
        switch state {
        case SqButtonState.PRESS:
            if let event = try? MIDIEvent.noteOn(MIDINote(sk),
                                                 velocity: MIDIEvent.NoteVelocity.midi1(UInt7("7F".hex!.value)),
                                                 channel: UInt4(midiChannel - 1))
            {
                return event
            } else {
                return nil
            }
        case SqButtonState.RELEASE:
            if let event = try? MIDIEvent.noteOff(MIDINote(sk),
                                                  velocity: MIDIEvent.NoteVelocity.midi1(UInt7("00".hex!.value)),
                                                  channel: UInt4(midiChannel - 1))
            {
                return event
            } else {
                return nil
            }
        }
    }

    private func channelByte(_ midiChannel: Int, flag: String = "B") -> String {
        let hex = String(midiChannel - 1, radix: 16).uppercased()
        return "\(flag)\(hex)"
    }
}
