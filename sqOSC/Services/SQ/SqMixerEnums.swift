//
//  SqMixerEnums.swift
//  sqOSC
//
//  Created by H Allen Adams on 7/5/24.
//

import Foundation

/**
 Define the basic Mixer Operation types
 */
enum EndpointOperationType: Int, CaseIterable, Identifiable {
    var id: Self { self }

    case mute = 0
    case sendLevel
    case pan
    case level
    case balance
    case trigger
    case recall

    public var title: String {
        switch self {
        case .balance: "Output Balance"
        case .level: "Output Level"
        case .mute: "Channel Mute"
        case .pan: "Channel Send Pan / Balance"
        case .recall: "Scene Recall"
        case .sendLevel: "Channel Send Level"
        case .trigger: "SoftKey Control"
        }
    }

    public var valueRange: ClosedRange<Double> {
        switch self {
        case .balance: -100 ... 100
        case .level: -100 ... 10
        case .pan: -100 ... 100
        case .sendLevel: -100 ... 10
        default: 0 ... 0
        }
    }

    public var units: String {
        switch self {
        case .balance: "%"
        case .level: "dB"
        case .mute: ""
        case .pan: "%"
        case .recall: ""
        case .sendLevel: "dB"
        case .trigger: ""
        }
    }

    func parameters() -> String {
        switch self {
        case .balance: return "{-100..100}"
        case .level: return "{-100..10}"
        case .mute: return "{ON|OFF}"
        case .pan: return "{-100..100}"
        case .recall: return "{1..300}"
        case .sendLevel: return "{-100..10}"
        case .trigger: return"{PRESS|RELEASE}"
        }
    }
}

/**
 Define the basic Mixer Channel / OSC Endpoint types
 */
enum EndpointType: String, CaseIterable, Codable, Identifiable {
    var id: Self { self }

    case input
    case group
    case fxReturn
    case main
    case aux
    case fxSend
    case matrix
    case dca
    case muteGroup
    case scene
    case keys
}

enum SqButtonState: String {
    case PRESS
    case RELEASE
}

enum SqMuteAction: String {
    case ON
    case OFF
    case TOGGLE
}
