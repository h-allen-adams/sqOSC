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
    private let channelCounts: [String: Int]

    /**
     Channel Operations (mute, level, balence) affect signal on a single
     channel.
     [ operation: [channel : parameter value (hex) ]]
     */
    private let channelParameters: [String: [String: String]]

    /**
     Channel-to-Channel Operations (sendLevel, pan) affect how signal moves
     from a source channel to a destination channel.
     [operation: [source: [ dest: parameter value (hex) ]]]
     */
    private let channelToChannelParameters: [String: [String: [String: String]]]

    /**
     Return the number of channels associated with the given channel/endpoint type
     */
    func channelCount(_ channelType: EndpointType) -> Int? {
        return channelCounts[channelType.rawValue]
    }

    /**
     Return the list of channels/source channels supported by the given
     operation. For recall and trigger this is a fixed value; for all others the
     list of channelParameters/channelToChannelParameter keys is returned.
     */
    func channelsFor(_ operation: EndpointOperationType) -> [EndpointType] {
        switch operation {
        case .recall:
            return [.scene]
        case .trigger:
            return [.keys]
        default:
            let opkey = String(describing: operation)
            if let channelParameter = channelParameters[opkey] {
                return channelParameter.keys.map { key in
                    EndpointType(rawValue: key)!
                }
            } else if let channelParameter = channelToChannelParameters[opkey] {
                return channelParameter.keys.map { key in
                    EndpointType(rawValue: key)!
                }
            } else {
                return []
            }
        }
    }

    /**
     Return true if the given operation supports the given channel, false
     otherwise.
     */
    func channelSupports(_ operation: EndpointOperationType,
                         _ channel: EndpointType) -> Bool
    {
        let opkey = String(describing: operation)
        if let channelParameter = channelParameters[opkey] {
            return channelParameter.keys.contains(channel.rawValue)
        } else if let channelParameter = channelToChannelParameters[opkey] {
            return channelParameter.keys.contains(channel.rawValue)
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
    func channelParameter(_ operation: EndpointOperationType,
                          _ channel: EndpointType) -> Int?
    {
        let opkey = String(describing: operation)
        if let parameterString = channelParameters[opkey]?[channel.rawValue] {
            let bytes = parameterString.split(separator: " ")
            return Values.toParameterNumber(String(bytes[0]), String(bytes[1]))
        }
        return nil
    }

    /**
     Return the list of destination channels for the given operation and source
     channel.
     */
    func channelTargets(_ operation: EndpointOperationType,
                        source: EndpointType) -> [EndpointType]
    {
        let opkey = String(describing: operation)
        if let dict = channelToChannelParameters[opkey]?[source.rawValue] {
            let keys = dict.keys

            return keys.map { key in
                EndpointType(rawValue: key)!
            }
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
    func channelToChannelParameter(_ operation: EndpointOperationType,
                                   source: EndpointType,
                                   dest: EndpointType) -> Int?
    {
        let opkey = String(describing: operation)
        if let parameterString = channelToChannelParameters[opkey]?[source.rawValue]?[dest.rawValue] {
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
