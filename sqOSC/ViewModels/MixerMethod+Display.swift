//
//  SqMixerEnums+Display.swift
//  sqOSC
//
//  Created by H Allen Adams on 10/3/25.
//

import Foundation

/**
 Extension adding UI display strings to EndpointOperationType
 */
extension MixerMethod {
    /**
     Human-Readable Title shown on Dictionary and Builder UI tabs
     */
    var title: String {
        switch self {
        case .assign: "Mix Assignment"
        case .balance: "Output Balance"
        case .level: "Output Level"
        case .mute: "Channel Mute"
        case .pan: "Channel Send Pan / Balance"
        case .recall: "Scene Recall"
        case .sendLevel: "Channel Send Level"
        case .trigger: "SoftKey Control"
        }
    }

    var valueRange: ClosedRange<Double> {
        switch self {
        case .balance, .pan: -100 ... 100
        case .level, .sendLevel: -100 ... 10
        default: 0 ... 0
        }
    }

    var units: String {
        switch self {
        case .balance, .pan: "%"
        case .level, .sendLevel: "dB"
        default: ""
        }
    }
}
