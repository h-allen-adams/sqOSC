//
//  SqMixerEnums.swift
//  sqOSC
//
//  Created by H Allen Adams on 7/5/24.
//

import Foundation

enum SqButtonState: String {
    case PRESS
    case RELEASE
}

enum SqChannelType: String {
    case input
    case group
    case fxReturn
    case main
    case aux
    case fxSend
    case matrix
    case dca
    case muteGroup
    case none

    func isOutputLevel() -> Bool {
        switch self {
        case .main, .aux, .fxSend, .matrix, .dca:
            return true
        default:
            return false
        }
    }

    func hasSends() -> Bool {
        switch self {
        case .input, .fxReturn, .group, .main, .aux:
            return true
        default:
            return false
        }
    }
}

enum SqMuteAction: String {
    case ON
    case OFF
    case TOGGLE
}
