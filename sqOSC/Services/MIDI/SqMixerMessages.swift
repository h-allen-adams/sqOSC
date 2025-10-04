//
//  SqMixerMessages.swift
//  sqOSC
//
//  Created by H Allen Adams on 7/5/24.
//

import Foundation
import MIDIKitCore
import SwiftRadix

/**
 Generate Mixer MIDI Messages. Each message function generates a MIDIEvent
 which can then be sent to a MIDI destination via the MIDI Manager.

 Message formats come from the Allen & Heath SQ MIDI Control Protocol
 Specification (linked below). In general, while both absolute and relative
 (increment/decrement) messages are given in the specification for most method
 types, this implementation supports only absolute messages. For example, the
 output level can be set to a specific dB value, but cannot be
 incremented/decremented by 1dB. Relative messages may be supported in the
 future.

 Most mixer control messages take the form of MIDI Non-Registered Parameter
 Number (NRPN) messages, which consist of a Parameter Number which identifies
 the value to be changed and a Parameter Value which encodes the new value. Both
 the Parameter Number and Parameter Value are split into a high and low byte in
 order to fit in the NPRN message format.

 Only MIDI 1.0 messages are supported by the mixer.

 See https://www.allen-heath.com/media/SQ-MIDI-Protocol-Issue1.pdf
 */
class SqMixerMessages
{
    let mixerConfig = SqMixerConfig.singletonInstance()

    /**
     Generate an Output Level message to set the audio level on the
     outputChannel. The format of these messages is documented in specification
     section 3.4 "Levels". Audio Level values are encoded using the Linear
     Fader Law.

     Retrieve the initial parameter number (pn0) for the channel type from the
     mixer configuration. Find the zero-based channel number and add to pn0 to
     obtain the final parameter number (pn).

     BN 63 MB BN 62 LB BN 06 VC BN 26 VF
     */
    func outputLevelMessage(midiChannel: Int,
                            outputType: MixerEndpoint,
                            outputChannel: Int,
                            dbLevel: Int) -> MIDIEvent?
    {
        if let pn0 = mixerConfig.channelParameter(.level, outputType)
        {
            let pn = pn0 + outputChannel - 1
            let pv = linearFader(dbLevel: dbLevel)
            return MIDIEvent.nrpn(parameter: toNrpnParam(pn),
                                  data: (UInt7(pv / 128), UInt7(pv % 128)),
                                  channel: UInt4(midiChannel - 1))
        }
        return nil
    }

    /**
     Generate a Pan/Balance message to set the audio balance on the output
     channel. The format of these messages is documented in specification
     3.5 "Panning/Balance".
     */
    func outputBalanceMessage(midiChannel: Int,
                              outputType: MixerEndpoint,
                              outputChannel: Int,
                              panLevel: Int) -> MIDIEvent?
    {
        if let pn0 = mixerConfig.channelParameter(.balance, outputType)
        {
            let pn = pn0 + outputChannel - 1
            let pv = panValue(panLevel: panLevel)
            return MIDIEvent.nrpn(parameter: toNrpnParam(pn),
                                  data: toNrpnData(pv),
                                  channel: UInt4(midiChannel - 1))
        }
        return nil
    }

    /**
     Generate a mute message to set or toggle the mute status od the specified
     channel. The format of these messages is documented in specification 3.3
     "Mutes".
     */
    func muteMessage(midiChannel: Int,
                     type: MixerEndpoint,
                     channel: Int,
                     action: SqMuteAction) -> MIDIEvent?
    {
        if let pn0 = mixerConfig.channelParameter(.mute, type)
        {
            let pn = pn0 + channel - 1

            switch action
            {
            case SqMuteAction.ON:
                return MIDIEvent.nrpn(parameter: toNrpnParam(pn),
                                      data: (UInt7(0), UInt7(1)),
                                      channel: UInt4(midiChannel - 1))
            case SqMuteAction.OFF:
                return MIDIEvent.nrpn(parameter: toNrpnParam(pn),
                                      data: (UInt7(0), UInt7(0)),
                                      channel: UInt4(midiChannel - 1))
            case SqMuteAction.TOGGLE:
                let controller =
                    MIDIEvent.AssignableController.raw(parameter: toNrpnParam(pn),
                                                       dataEntryMSB: UInt7("60".hex!.value),
                                                       dataEntryLSB: nil)
                return MIDIEvent.nrpn(controller,
                                      channel: UInt4(midiChannel - 1))
            }
        }
        return nil
    }

    /**
     Generate a Send Level message to set the audio level sent from the
     sourceChannel to the destChannel. The format of these messages is
     documented in specification section 3.4 "Levels". Audio Level values are
     encoded using the Linear Fader Law.

     Retrieve the initial parameter number (pn0) for the source and dest channel
     type pair from the mixer configuration. The final parameter number is the
     row offset (total number of destination channels multipled by the zero-based
     source channel number) plus the column offset (zero-based destination channel
     number).
     */
    func sendLevelMessage(midiChannel: Int,
                          sourceType: MixerEndpoint,
                          sourceChannel: Int,
                          destType: MixerEndpoint,
                          destChannel: Int,
                          dbLevel: Int) -> MIDIEvent?
    {
        guard let numCols = mixerConfig.channelCount(destType) else { return nil }
        guard let pn0 =
            mixerConfig.channelToChannelParameter(.sendLevel,
                                                  source: sourceType,
                                                  dest: destType) else { return nil }
        let pn = pn0 + numCols * (sourceChannel - 1) + (destChannel - 1)
        let pv = linearFader(dbLevel: dbLevel)
        return MIDIEvent.nrpn(parameter: toNrpnParam(pn),
                              data: toNrpnData(pv),
                              channel: UInt4(midiChannel - 1))
    }

    /**
     Generate a Pan/Balance message to set the audio pan of the audio sent from
     the source channel to the destination channel. The format of these messages
     is documented in specification 3.5 "Panning/Balance".
     */
    func sendPanMessage(midiChannel: Int,
                        sourceType: MixerEndpoint,
                        sourceChannel: Int,
                        destType: MixerEndpoint,
                        destChannel: Int,
                        panLevel: Int) -> MIDIEvent?
    {
        guard let numCols = mixerConfig.channelCount(destType) else { return nil }
        guard let pn0 = mixerConfig.channelToChannelParameter(.pan,
                                                              source: sourceType,
                                                              dest: destType) else { return nil }
        let pn = pn0 + numCols * (sourceChannel - 1) + (destChannel - 1)
        let pv = panValue(panLevel: panLevel)
        return MIDIEvent.nrpn(parameter: toNrpnParam(pn),
                              data: toNrpnData(pv),
                              channel: UInt4(midiChannel - 1))
    }

    /**
     Generate a Scene Change MIDI Message to recall the specified scene. Scene
     change messages are documented in specification 3.1 "Scene Change" and
     consists of a bank change followed by a program change: "BN 00 BK CN PG"
     Where: N= MIDI Channel, BK = Bank, PG = Program
     */
    func sceneRecallMessage(midiChannel: Int,
                            scene: Int) -> MIDIEvent?
    {
        let bk = scene / 128
        let pg = (scene % 128) - 1
        let event = MIDIEvent.programChange(program: UInt7(pg),
                                            bank: MIDIEvent.ProgramChange.Bank.bankSelect(UInt14(bk)),
                                            channel: UInt4(midiChannel) - 1)
        return event
    }

    /**
     Generate a Soft Key MIDI Message press or release the speicifed soft key.
     These messages are documented in specification 3.3 "Soft Keys" and consists
     of a Note ON and Note OFF messages.
     */
    func softKeyMessage(midiChannel: Int,
                        button: Int,
                        state: SqButtonState) -> MIDIEvent?
    {
        let sk = Values.hexToDec("30") + button - 1
        switch state
        {
        case SqButtonState.PRESS:
            return try? MIDIEvent.noteOn(MIDINote(sk),
                                         velocity: MIDIEvent.NoteVelocity.midi1(UInt7("7F".hex!.value)),
                                         channel: UInt4(midiChannel - 1))
        case SqButtonState.RELEASE:
            return try? MIDIEvent.noteOff(MIDINote(sk),
                                          velocity: MIDIEvent.NoteVelocity.midi1(UInt7("00".hex!.value)),
                                          channel: UInt4(midiChannel - 1))
        }
    }

    private func channelByte(_ midiChannel: Int, flag: String = "B") -> String
    {
        let hex = String(midiChannel - 1, radix: 16).uppercased()
        return "\(flag)\(hex)"
    }

    /**
     Audio Level values are encoded using the Linear Fader Law (Specification 3.4)
     which is the default mixer setting and is easier to implement.

     Linear adjustments are based on 16384 possible values, approx 119 values
     per dB. +10db is value 16384, so scale down from there.
     */
    func linearFader(dbLevel: Int) -> Int
    {
        var workingDb = dbLevel
        if workingDb > 10 { workingDb = 10 }
        if workingDb < -89 { return 0 }
        let adjustedDB = workingDb - 10
        let delta = Int(round(Double(adjustedDB) * 118.72))
        let v = 16383 + delta
        return v
    }

    // Pan -100: 00 00, 0: 3F 7F, 100: 7F 7F
    func panValue(panLevel: Int) -> Int
    {
        let zero = Values.toParameterNumber("3F", "7F")
        let factor = Double(zero) / 100.0
        var workingLevel = panLevel
        if workingLevel > 100 { workingLevel = 100 }
        if workingLevel < -100 { workingLevel = -100 }
        let v = zero + Int(round(Double(workingLevel) * factor))
        return v
    }

    /**
     Construct a UInt7Pair where the MSB (high) byte is value / 128, and the LSB
     (low) byte is value mod 128.
     */
    private func toNrpnParam(_ value: Int) -> UInt7Pair
    {
        return UInt7Pair(msb: UInt7(value / 128), lsb: UInt7(value % 128))
    }

    /**
     Construct a Tuple where the MSB (high) byte is value / 128, and the LSB
     (low) byte is value mod 128.
     */
    private func toNrpnData(_ value: Int) -> (UInt7?, UInt7?)
    {
        return (msb: UInt7(value / 128), lsb: UInt7(value % 128))
    }
}
