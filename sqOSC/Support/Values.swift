//
//  Values.swift
//  sqOSC
//
//  Created by H Allen Adams on 7/5/24.
//

import Foundation

class Values {
    static func toParameterNumber(_ msb: String, _ lsb: String) -> Int {
        return hexToDec(msb) * 128 + hexToDec(lsb)
    }

    static func toMsbLsb(_ pn: Int) -> (msb: String, lsb: String) {
        let msb = Values.decToHex(pn / 128)
        let lsb = Values.decToHex(pn % 128)
        return (msb, lsb)
    }

    static func hexToDec(_ hex: String) -> Int {
        guard let toConvert = hex.hex else { return 0 }
        return toConvert.value
    }

    static func decToHex(_ dec: Int, minLength: Int = 2) -> String {
        return dec.hex.stringValue(padTo: minLength)
    }
}
