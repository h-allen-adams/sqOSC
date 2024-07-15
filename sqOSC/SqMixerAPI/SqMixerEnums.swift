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
    case level
    case trigger
    case recall

    public var title: String {
        switch self {
        case .level: "Output Levels"
        case .mute: "Mute Channels"
        case .recall: "Scene Recall"
        case .sendLevel: "Send Levels"
        case .trigger: "SoftKey Control"
        }
    }

    func parameters() -> String {
        switch self {
        case .level: return "{-100..10}"
        case .mute: return "{ON|OFF}"
        case .recall: return "{1..300}"
        case .sendLevel: return "{-100..10}"
        case .trigger: return"{PRESS|RELEASE}"
        }
    }

    public var endpoints: [EndpointType] {
        switch self {
        case .level: [EndpointType.aux,
                      EndpointType.dca,
                      EndpointType.fxSend,
                      EndpointType.main,
                      EndpointType.matrix]
        case .mute: [EndpointType.aux,
                     EndpointType.dca,
                     EndpointType.fxReturn,
                     EndpointType.fxSend,
                     EndpointType.group,
                     EndpointType.input,
                     EndpointType.main,
                     EndpointType.matrix,
                     EndpointType.muteGroup]
        case .recall: [EndpointType.scene]
        case .sendLevel: [EndpointType.aux,
                          EndpointType.fxReturn,
                          EndpointType.group,
                          EndpointType.input,
                          EndpointType.main]
        case .trigger: [EndpointType.keys]
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
