//
//  SqMixerConfig.swift
//  sqOSC
//
//  Created by H Allen Adams on 9/16/25.
//

import Foundation

/**
 Singleton Mixer Configuration values based on the contents of the sq.plist
 file.
 */
class SqMixerConfig: Codable {
    private static let _instance = defaultConfig()

    /**
     Channel counts: [channel: count]
     */
    private let channelCounts: [MixerEndpoint: Int]

    /**
     Channel Operations (mute, level, balence) affect signal on a single
     channel.
     [ operation: [channel : parameter value (hex) ]]
     */
    private let channelParameters: [MixerMethod: [MixerEndpoint: String]]

    /**
     Channel-to-Channel Operations (sendLevel, pan) affect how signal moves
     from a source channel to a destination channel.
     [operation: [source: [ dest: parameter value (hex) ]]]
     */
    private let channelToChannelParameters:
        [MixerMethod: [MixerEndpoint: [MixerEndpoint: String]]]

    /**
     Return the number of channels associated with the given channel/endpoint type
     */
    func channelCount(_ channelType: MixerEndpoint) -> Int? {
        return channelCounts[channelType]
    }

    /**
     Return the list of channels/source channels supported by the given
     operation. For recall and trigger this is a fixed value; for all others the
     list of channelParameters/channelToChannelParameter keys is returned.
     */
    func channelsFor(_ operation: MixerMethod) -> [MixerEndpoint] {
        switch operation {
        case .recall:
            return [.scene]
        case .trigger:
            return [.keys]
        default:
            if let channelParameter = channelParameters[operation] {
                return Array(channelParameter.keys)
            } else if let channelParameter = channelToChannelParameters[operation] {
                return Array(channelParameter.keys)
            } else {
                return []
            }
        }
    }

    /**
     Return true if the given operation supports the given channel, false
     otherwise.
     */
    func channelSupports(_ operation: MixerMethod,
                         _ channel: MixerEndpoint) -> Bool
    {
        if let channelParameter = channelParameters[operation] {
            return channelParameter.keys.contains(channel)
        } else if let channelParameter = channelToChannelParameters[operation] {
            return channelParameter.keys.contains(channel)
        } else {
            return false
        }
    }

    /**
     Return the (integer) parameter value for the given operation and channel.
     If no parameter exists, return nil.  The parameter value returned is the
     value for the first channel in the operation group. For single channel
     operations the value is incremented for subsequent channels. For example,
     the mute parameter value for the first input channel is "00 00" and the
     second is "00 01".
     */
    func channelParameter(_ operation: MixerMethod,
                          _ channel: MixerEndpoint) -> Int?
    {
        if let parameterString = channelParameters[operation]?[channel] {
            let bytes = parameterString.split(separator: " ")
            return Values.toParameterNumber(String(bytes[0]), String(bytes[1]))
        }
        return nil
    }

    /**
     Return the list of destination channels for the given operation and source
     channel.
     */
    func channelTargets(_ operation: MixerMethod,
                        source: MixerEndpoint) -> [MixerEndpoint]
    {
        if let dict = channelToChannelParameters[operation]?[source] {
            return Array(dict.keys)
        }
        return []
    }

    /**
     Return the (integer) parameter value for the given operation, source, and
     dest channels. If no parameter exists, return nil.  The parameter value
     returned is the value for the first source/dest channel pair in the
     operation group. For channel-to-channel operations values are incremented
     across, then down: "40 44" is the send level parameter for input channel 1
     to aux 1, "40 45" for input 1 to aux 2 incrementing across the 12 possible
     auxes. Input channel 2 to aux 1 starts over at "40 50".
     */
    func channelToChannelParameter(_ operation: MixerMethod,
                                   source: MixerEndpoint,
                                   dest: MixerEndpoint) -> Int?
    {
        if let parameterString = channelToChannelParameters[operation]?[source]?[dest] {
            let bytes = parameterString.split(separator: " ")
            return Values.toParameterNumber(String(bytes[0]), String(bytes[1]))
        }
        return nil
    }

    /**
     Return the singleton instance
     */
    static func singletonInstance() -> SqMixerConfig {
        return _instance
    }

    /**
     Initialize an instance by readling the sq.plist file
     */
    private static func defaultConfig() -> SqMixerConfig {
        let settingsUrl = Bundle.main.url(forResource: "sq", withExtension: "plist")
        let settingsData = try! Data(contentsOf: settingsUrl!)
        do {
            let decoder = PropertyListDecoder()
            return try decoder.decode(SqMixerConfig.self, from: settingsData)
        } catch {
            fatalError("Unable to decode sq.plist")
        }
    }
}
