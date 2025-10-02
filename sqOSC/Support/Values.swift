//
//  Values.swift
//  sqOSC
//
//  Created by H Allen Adams on 7/5/24.
//

import Foundation

/**
 Utilities to convert MIDI parameter values between integers and hex strings.
 */
class Values {
    /**
     Convert the given two hex values into an integer parameter value.
     */
    static func toParameterNumber(_ msb: String, _ lsb: String) -> Int {
        return hexToDec(msb) * 128 + hexToDec(lsb)
    }

    /**
     Convert the given integer parameter value to a pair of hex values.
     */
    static func toMsbLsb(_ pn: Int) -> (msb: String, lsb: String) {
        let msb = Values.decToHex(pn / 128)
        let lsb = Values.decToHex(pn % 128)
        return (msb, lsb)
    }

    /**
     Convert a hex number to integer
     */
    static func hexToDec(_ hex: String) -> Int {
        guard let toConvert = hex.hex else { return 0 }
        return toConvert.value
    }

    /**
     Convert an integer to a hex string
     */
    static func decToHex(_ dec: Int, minLength: Int = 2) -> String {
        return dec.hex.stringValue(padTo: minLength)
    }
}
