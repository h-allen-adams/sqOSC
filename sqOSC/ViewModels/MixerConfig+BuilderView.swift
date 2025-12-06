//
//  MixerConfig+BuilderView.swift
//  sqOSC
//
//  Created by H Allen Adams on 11/15/25.
//

import Foundation

/**
 MixerConfig extension to power the Builder Views
 */
extension MixerConfig {
    /**
     Enum to group Mixer Endpoints for UI Display. MixerEndpoints are defined
     by their underlying mixer parameter numbers, but this is not always the
     best organization for dispaly. For example, Qu and CQ mixers define special
     ST, USB, and Bluetooth Inputs. If the UI is built on raw endpoint types,
     these would appear in separate lists than the regular inputs.
     BuilderChannelType allows organization of channels together in logical
     groups easier for users to use.
     */
    enum BuilderChannelType:
        String,
        CaseIterable,
        Comparable,
        Identifiable
    {
        var id: Self { self }

        case input
        case output
        case group
        case fxSend
        case fxReturn
        case matrix
        case dca
        case muteGroup
        case scene
        case keys

        /** Human-Readable Title for UI Display */
        var title: String {
            switch self {
            case .input: return "Input"
            case .output: return "Output"
            case .group: return "Group"
            case .fxSend: return "FX Send"
            case .fxReturn: return "FX Return"
            case .matrix: return "Matrix"
            case .dca: return "DCA"
            case .muteGroup: return "Mute Group"
            case .scene: return "Scene"
            case .keys: return "Soft Key"
            }
        }
        
        /** Groups of MixerEndpoints for UI Display */
        var mixerEndpoints: [MixerEndpoint] {
            switch self {
            case .input: return [.input, .st, .usb, .bt]
            case .output: return [.main, .aux]
            case .group: return [.group]
            case .fxSend: return [.fxSend]
            case .fxReturn: return [.fxReturn]
            case .matrix: return [.matrix]
            case .dca: return [.dca]
            case .muteGroup: return [.muteGroup]
            case .scene: return [.scene]
            case .keys: return [.keys]
            }
        }

        /** Sort Order */
        var sortedOrder: Int {
            switch self {
            case .input: 0
            case .output: 1
            case .group: 2
            case .fxSend: 3
            case .fxReturn: 4
            case .matrix: 5
            case .dca: 6
            case .muteGroup: 7
            case .scene: 8
            case .keys: 9
            }
        }

        /** Sort Function */
        static func < (lhs: BuilderChannelType, rhs: BuilderChannelType) -> Bool {
            return lhs.sortedOrder < rhs.sortedOrder
        }
        
        /** Return the BuilderCHannelType for a MixerEndpoint */
        static func forEndpoint(_ endpoint: MixerEndpoint) -> BuilderChannelType {
            switch endpoint {
            case .input: .input
            case .st: .input
            case .usb: .input
            case .bt: .input
            case .main: .output
            case .aux: .output
            case .group: .group
            case .fxSend: .fxSend
            case .fxReturn: .fxReturn
            case .matrix: .matrix
            case .dca: .dca
            case .muteGroup: .muteGroup
            case .scene: .scene
            case .keys: .keys
            }
        }
    }
    
    /**
     Build a BuilderChannelType array for a MixerMethod. Iterate over the
     MixerEndpoints supported by the method and create a BuilderCHannelType for
     each.
     */
    func builderChannelTypeFor(_ method: MixerMethod) -> [BuilderChannelType] {
        var builderChannels: Set<BuilderChannelType> = []
        
        channelsFor(method).forEach { mixerEndpoint in
            builderChannels.insert(BuilderChannelType.forEndpoint(mixerEndpoint))
        }
        
        return builderChannels.sorted()
    }
    
    /**
     Builder Channels are used to pupulate the UI dropdowns. Each associates a
     MixerEndpoint, channel number, and human-readbale title for display in UI
     dropdowns.
     */
    struct BuilderChannel: Hashable {
        let endpoint: MixerEndpoint
        let chNum: Int
        let title: String
        
        static let UNRESOLVED: BuilderChannel = .init(endpoint: .input, chNum: 1, title: "UNRESOLVED")
    }
        
    /**
     Build an array of BuilderCHannels by grouping all the related mixer
     endpoints and their human-readbale titles.
     */
    func builderChannels(_ channelType: BuilderChannelType) -> [BuilderChannel] {
        var builderChannels: [BuilderChannel] = []
        
        channelType.mixerEndpoints.forEach { mixerEndpoint in
            if let numChannels = channelCount(mixerEndpoint) {
                if numChannels == 1 {
                    let title = mixerEndpoint.sourceTitle
                    builderChannels.append(BuilderChannel(endpoint: mixerEndpoint, chNum: 1, title: title))
                } else {
                    for chNum in 1 ... numChannels {
                        let title = "\(mixerEndpoint.sourceTitle) \(chNum)"
                        builderChannels.append(BuilderChannel(endpoint: mixerEndpoint, chNum: chNum, title: title))
                    }
                }
            }
        }
        
        return builderChannels
    }
    
    func builderChannelTargets(_ method: MixerMethod, source: BuilderChannelType) -> [BuilderChannelType] {
        var builderChannels: Set<BuilderChannelType> = []
        
        source.mixerEndpoints.forEach { sourceEndpoint in
            channelTargets(method, source: sourceEndpoint).forEach { mixerEndpoint in
                builderChannels.insert(BuilderChannelType.forEndpoint(mixerEndpoint))
            }
        }
        
        return builderChannels.sorted()
    }
}

extension MixerEndpoint {
    /** Human-Readable Title for UI Display */
    var sourceTitle: String {
        switch self {
        case .input: "Ip"
        case .st: "ST"
        case .usb: "USB"
        case .bt: "Bluetooth"
        case .main: "Main LR"
        case .aux: "Aux"
        case .group: "Group"
        case .fxSend: "FX Send"
        case .fxReturn: "FX Return"
        case .matrix: "Matrix"
        case .dca: "DCA"
        case .muteGroup: "Mute Group"
        case .scene: "Scene"
        case .keys: "Softkey"
        }
    }
}
