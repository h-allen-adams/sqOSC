//
//  SqMixerEnums.swift
//  sqOSC
//
//  Created by H Allen Adams on 7/5/24.
//

import Foundation

enum MixerModel: String, Codable, CaseIterable, CodingKeyRepresentable, Identifiable {
    var id: Self { self }

    case sq
}

/**
 Define the basic Mixer Operation types. These values map directly to OSC
 Methods in our OSC Address Space.
 */
enum MixerMethod:
    String,
    CaseIterable,
    Codable,
    CodingKeyRepresentable,
    Identifiable
{
    var id: Self { self }

    case mute
    case sendLevel
    case pan
    case assign
    case level
    case balance
    case trigger
    case recall
}

/**
 Define the basic controllable Mixer targets (Channels, Mute Groops, Soft Keys,
 and Scenes). These values map directly to the primary OSC Containers in our
 OSC Address Space.
 */
enum MixerEndpoint:
    String,
    CaseIterable,
    Codable,
    CodingKeyRepresentable,
    Identifiable
{
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

    static var audioCases: [MixerEndpoint] {
        return [.input, .group, .fxReturn, .main, .aux, .fxSend, .matrix, .dca, .muteGroup]
    }
}

enum SqButtonState: String {
    case PRESS
    case RELEASE
}

enum SqToggleAction: String, CaseIterable {
    case ON
    case OFF
}
