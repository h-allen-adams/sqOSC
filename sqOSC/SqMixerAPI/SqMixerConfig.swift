//
//  SqMixerConfig.swift
//  sqOSC
//
//  Created by H Allen Adams on 9/16/25.
//

import Foundation

class SqMixerConfig: Codable {
    private static let _instance = defaultConfig()

    private let channelCounts: [String: Int]
    private let channelParameters: [String: [String: String]]
    private let channelToChannelParameters: [String: [String: [String: String]]]

    func channelCount(_ channelType: EndpointType) -> Int? {
        return channelCounts[channelType.rawValue]
    }

    func channelsFor(_ operation: EndpointOperationType) -> [EndpointType] {
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

    static func singletonInstance() -> SqMixerConfig {
        return _instance
    }

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
