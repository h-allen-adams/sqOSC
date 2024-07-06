//
//  SqMixerEnums.swift
//  sqOSC
//
//  Created by H Allen Adams on 7/5/24.
//

import Foundation

enum EndpointOperationType: Int, CaseIterable {
    case recall = 0
    case trigger
    case mute
    case level
    case sendLevel

    func endpoints() -> [EndpointType] {
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
