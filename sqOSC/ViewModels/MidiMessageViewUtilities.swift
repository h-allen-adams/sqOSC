//
//  OSCMessageView.swift
//  sqOSC
//
//  Created by H Allen Adams on 9/12/25.
//

import OSCKitCore
import SwiftUI

/**
 Utitlity class providing methods for formatting MIDI messages for display.
 */
struct MidiMessageViewUtilities {
    /**
     Colorize an NRPN MIDI string for display
     */
    static func colorizeNrpn(_ midiMessageString: inout AttributedString) {
        let msbStartIndex = midiMessageString.index(midiMessageString.startIndex, offsetByCharacters: 6)
        let msbEndIndex = midiMessageString.index(msbStartIndex, offsetByCharacters: 2)
        midiMessageString[msbStartIndex ..< msbEndIndex].foregroundColor = .red

        let lsbStartIndex = midiMessageString.index(midiMessageString.startIndex, offsetByCharacters: 15)
        let lsbEndIndex = midiMessageString.index(lsbStartIndex, offsetByCharacters: 2)
        midiMessageString[lsbStartIndex ..< lsbEndIndex].foregroundColor = .red

        let vcStartIndex = midiMessageString.index(midiMessageString.startIndex, offsetByCharacters: 24)
        let vcEndIndex = midiMessageString.index(vcStartIndex, offsetByCharacters: 2)
        midiMessageString[vcStartIndex ..< vcEndIndex].foregroundColor = .blue

        let vfStartIndex = midiMessageString.index(midiMessageString.startIndex, offsetByCharacters: 33)
        let vfEndIndex = midiMessageString.index(vfStartIndex, offsetByCharacters: 2)
        midiMessageString[vfStartIndex ..< vfEndIndex].foregroundColor = .blue
    }
}
