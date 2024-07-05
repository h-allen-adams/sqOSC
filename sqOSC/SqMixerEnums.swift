//
//  SqMixerEnums.swift
//  sqOSC
//
//  Created by H Allen Adams on 7/5/24.
//

import Foundation

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
}

enum SqMuteAction: String {
    case ON
    case OFF
    case TOGGLE
}
