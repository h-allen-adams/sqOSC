//
//  SqMixerEnums.swift
//  sqOSC
//
//  Created by H Allen Adams on 7/5/24.
//

import Foundation

enum EndpointOperationType: Int, CaseIterable {
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
        case .level: "Output Levels"
        case .mute: "Mute Channels"
        case .pan: "Send Pan / Balance"
        case .recall: "Scene Recall"
        case .sendLevel: "Send Levels"
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

enum EndpointType: String, CaseIterable {
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

    public var count: Int {
        switch self {
        case .aux: 12
        case .dca: 8
        case .fxReturn: 8
        case .fxSend: 4
        case .group: 12
        case .input: 48
        case .keys: 16
        case .main: 1
        case .matrix: 3
        case .muteGroup: 8
        case .scene: 1
        }
    }

    func isOutputBalance() -> Bool {
        switch self {
        case .main, .aux, .matrix:
            return true
        default:
            return false
        }
    }

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

    func basePath() -> String {
        switch self {
        case .aux: "/sq/aux/{chNum}"
        case .dca: "/sq/dca/{chNum}"
        case .fxReturn: "/sq/fxReturn/{chNum}"
        case .fxSend: "/sq/fxSend/{chNum}"
        case .group: "/sq/group/{chNum}"
        case .input: "/sq/input/{chNum}"
        case .keys: "/sq/softKey/{keyNum}"
        case .main: "/sq/main"
        case .matrix: "/sq/matrix/{chNum}"
        case .muteGroup: "/sq/muteGroup/{chNum}"
        case .scene: "/sq/scene"
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
