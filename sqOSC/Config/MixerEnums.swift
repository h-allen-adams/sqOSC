//
//  SqMixerEnums.swift
//  sqOSC
//
//  Created by H Allen Adams on 7/5/24.
//

import Foundation

/**
 Define the Mixer Series supported by the application
 */
enum MixerSeries:
    String,
    Codable,
    CaseIterable,
    CodingKeyRepresentable,
    Identifiable
{
    var id: Self { self }

    case sq
    case qu
    case cq
    case none

    static var displayCases: [MixerSeries]
    {
        return [.sq, .qu, .cq]
    }
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
    Comparable,
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

    var hasDest: Bool
    {
        switch self
        {
        case .assign, .sendLevel, .pan: true
        default: false
        }
    }

    var sortedOrder: Int
    {
        switch self
        {
        case .mute: 0
        case .sendLevel: 1
        case .pan: 2
        case .assign: 3
        case .level: 4
        case .balance: 5
        case .trigger: 6
        case .recall: 7
        }
    }

    static func < (lhs: MixerMethod, rhs: MixerMethod) -> Bool
    {
        return lhs.sortedOrder < rhs.sortedOrder
    }
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
    Comparable,
    Identifiable
{
    var id: Self { self }

    case input
    case st
    case usb
    case bt
    case main
    case aux
    case group
    case fxSend
    case fxReturn
    case matrix
    case dca
    case muteGroup
    case scene
    case keys

    var sortedOrder: Int
    {
        switch self
        {
        case .input: 0
        case .st: 1
        case .usb: 2
        case .bt: 3
        case .main: 4
        case .aux: 5
        case .group: 6
        case .fxSend: 7
        case .fxReturn: 8
        case .matrix: 9
        case .dca: 10
        case .muteGroup: 11
        case .scene: 12
        case .keys: 13
        }
    }

    static var audioCases: [MixerEndpoint]
    {
        return [.input, .st, .usb, .bt, .main, .aux, .group, .fxSend, .fxReturn, .matrix, .dca, .muteGroup]
    }

    static func < (lhs: MixerEndpoint, rhs: MixerEndpoint) -> Bool
    {
        return lhs.sortedOrder < rhs.sortedOrder
    }
}

enum SqButtonState: String
{
    case PRESS
    case RELEASE
}

enum SqToggleAction: String, CaseIterable
{
    case ON
    case OFF
}

enum FaderLevelLaw:
    String,
    CaseIterable,
    Codable,
    CodingKeyRepresentable,
    Comparable
{
    case LinearTaper
    case AudioTaper

    var sortedOrder: Int
    {
        switch self
        {
        case .LinearTaper: return 0
        case .AudioTaper: return 1
        }
    }

    static func < (lhs: FaderLevelLaw, rhs: FaderLevelLaw) -> Bool
    {
        return lhs.sortedOrder < rhs.sortedOrder
    }
}
