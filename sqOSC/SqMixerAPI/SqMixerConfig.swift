//
//  SqMixerConfig.swift
//  sqOSC
//
//  Created by H Allen Adams on 9/16/25.
//

import Foundation

class SqMixerConfig: Codable, ObservableObject {
    let parameters: EndpointOperationsConfig
    let endpoints: [String: EndpointConfig]

    func channelCount(_ channelType: EndpointType) -> Int? {
        return endpoints[channelType.rawValue]?.count
    }

    func channelSupports(_ operation: EndpointOperationType, _ channel: EndpointType) -> Bool {
        return parameters.supported(operation, channel)
    }

    func channelParameter(_ operation: EndpointOperationType, _ channel: EndpointType) -> Int? {
        if let parameterString = parameters.parameterFor(operation: operation, channel: channel) {
            let bytes = parameterString.split(separator: " ")
            return Values.toParameterNumber(String(bytes[0]), String(bytes[1]))
        }
        return nil
    }

    func channelTargets(_ operation: EndpointOperationType, source: EndpointType) -> [EndpointType] {
        return parameters.targetsFor(operation: operation, source: source) ?? []
    }

    func channelParameter(_ operation: EndpointOperationType, source: EndpointType, dest: EndpointType) -> Int? {
        if let parameterString = parameters.parameterFor(operation: operation, source: source, dest: dest) {
            let bytes = parameterString.split(separator: " ")
            return Values.toParameterNumber(String(bytes[0]), String(bytes[1]))
        }
        return nil
    }

    static func defaultConfig() -> SqMixerConfig {
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

struct EndpointConfig: Codable {
    let count: Int
}

struct EndpointOperationsConfig: Codable {
    let balance: [String: String]?
    let level: [String: String]?
    let mute: [String: String]?
    let pan: [String: [String: String]]?
    let recall: [String: String]?
    let sendLevel: [String: [String: String]]?
    let trigger: [String: String]?

    func supported(_ operation: EndpointOperationType, _ channel: EndpointType) -> Bool {
        switch operation {
        case .mute:
            return mute?.keys.contains(channel.rawValue) ?? false
        case .sendLevel:
            return sendLevel?.keys.contains(channel.rawValue) ?? false
        case .pan:
            return pan?.keys.contains(channel.rawValue) ?? false
        case .level:
            return level?.keys.contains(channel.rawValue) ?? false
        case .balance:
            return balance?.keys.contains(channel.rawValue) ?? false
        case .trigger:
            return trigger?.keys.contains(channel.rawValue) ?? false
        case .recall:
            return recall?.keys.contains(channel.rawValue) ?? false
        }
    }

    func parameterFor(operation: EndpointOperationType, channel: EndpointType) -> String? {
        switch operation {
        case .balance:
            return balance?[channel.rawValue]
        case .level:
            return level?[channel.rawValue]
        case .mute:
            return mute?[channel.rawValue]
        case .recall:
            return recall?[channel.rawValue]
        case .trigger:
            return trigger?[channel.rawValue]
        default:
            return nil
        }
    }

    func parameterFor(operation: EndpointOperationType, source: EndpointType, dest: EndpointType) -> String? {
        switch operation {
        case .sendLevel:
            return sendLevel?[source.rawValue]?[dest.rawValue]
        case .pan:
            return pan?[source.rawValue]?[dest.rawValue]
        default:
            return nil
        }
    }

    func targetsFor(operation: EndpointOperationType, source: EndpointType) -> [EndpointType]? {
        var dict: [String: String]?
        switch operation {
        case .sendLevel:
            dict = sendLevel?[source.rawValue]
        case .pan:
            dict = pan?[source.rawValue]
        default:
            return nil
        }
        if let keys = dict?.keys {
            return keys.map { key in
                EndpointType(rawValue: key)!
            }
        } else {
            return nil
        }
    }
}
