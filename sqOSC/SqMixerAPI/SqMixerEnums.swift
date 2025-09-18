//
//  SqMixerEnums.swift
//  sqOSC
//
//  Created by H Allen Adams on 7/5/24.
//

import Foundation

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

    public var endpoints: [EndpointType] {
        switch self {
        case .balance: [
                EndpointType.aux,
                EndpointType.main,
                EndpointType.matrix
            ]
        case .level: [
                EndpointType.aux,
                EndpointType.dca,
                EndpointType.fxSend,
                EndpointType.main,
                EndpointType.matrix
            ]
        case .mute: [
                EndpointType.aux,
                EndpointType.dca,
                EndpointType.fxReturn,
                EndpointType.fxSend,
                EndpointType.group,
                EndpointType.input,
                EndpointType.main,
                EndpointType.matrix,
                EndpointType.muteGroup
            ]
        case .pan: [
                EndpointType.aux,
                EndpointType.input,
                EndpointType.group,
                EndpointType.fxReturn,
                EndpointType.main
            ]
        case .recall: [
                EndpointType.scene
            ]
        case .sendLevel: [
                EndpointType.aux,
                EndpointType.fxReturn,
                EndpointType.group,
                EndpointType.input,
                EndpointType.main
            ]
        case .trigger: [
                EndpointType.keys
            ]
        }
    }
}

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

    public var sendTargets: [EndpointType] {
        switch self {
        case .input: [.main, .aux, .fxSend]
        case .fxReturn: [.main, .aux, .fxSend]
        case .group: [.main, .aux, .fxSend, .matrix]
        case .main: [.matrix]
        case .aux: [.matrix]
        default: []
        }
    }

    public var panTargets: [EndpointType] {
        switch self {
        case .input: [.main, .aux]
        case .fxReturn: [.main, .aux]
        case .group: [.main, .aux, .matrix]
        case .main: [.matrix]
        case .aux: [.matrix]
        default: []
        }
    }
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
