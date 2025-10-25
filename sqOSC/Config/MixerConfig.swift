//
//  SqMixerConfig.swift
//  sqOSC
//
//  Created by H Allen Adams on 9/16/25.
//

import Foundation

/**
 Singleton Mixer Configuration values based on the contents of the associated
 plist file.
 */
class MixerConfig: Codable, Equatable {
    public static let NONE = MixerConfig()
    
    /**
     Mixer Series
     */
    public let series: MixerSeries
    
    /**
     Channel counts: [channel: count]
     */
    private let channelCounts: [MixerEndpoint: Int]
    
    /**
     Channel offsets: [channel: count]
     */
    private let channelOffsets: [MixerEndpoint: Int]
    
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
     Soft Key Parameters (first note, press velocity, release velocity)
     */
    let softKeyParameters: SoftKeyParameters
        
    /**
     Pan/Balance Parameters (hex) indexed by pan value (-100 (L) ... 100 (R)).
     Values are taken from the A&H MIDI specification for a mixer series. These
     tables are SPARSE in that they do not contain entries for all values in the
     range, but MUST contain at least entries for the first and last values in
     the range.
     */
    private let panBalanceParameters: [Int: String]
    
    /**
     Fader/Send Level Parameters (hex) indexed by Fader Law and then dbLevel
     (-100...10). Values are taken from the A&H MIDI specification for a mixer
     series. These tables are SPARSE in that they do not contain entries for all
     values in the range, but MUST contain at least entries for the first and
     last values in the range.
     */
    private let levelParameters: [FaderLevelLaw: [Int: String]]
    
    private init() {
        series = .none
        channelCounts = [:]
        channelOffsets = [:]
        channelParameters = [:]
        channelToChannelParameters = [:]
        softKeyParameters = SoftKeyParameters()
        panBalanceParameters = [:]
        levelParameters = [:]
    }
    
    /**
     Return the sorted list of methods active in this configuration
     */
    func methods() -> [MixerMethod] {
        var methods: [MixerMethod] = []
        methods.append(contentsOf: channelParameters.keys)
        methods.append(contentsOf: channelToChannelParameters.keys)
        methods.append(.recall)
        methods.append(.trigger)
        return methods.sorted()
    }
    
    /**
     Return the number of channels associated with the given channel/endpoint type
     */
    func channelCount(_ channelType: MixerEndpoint) -> Int? {
        return channelCounts[channelType]
    }
    
    /**
     Return the parameter number offset for the given channel/endpoint type
     */
    func channelOffset(_ channelType: MixerEndpoint) -> Int {
        return channelOffsets[channelType] ?? 1
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
            var entries: [MixerEndpoint]
            if let channelParameter = channelParameters[operation] {
                entries = Array(channelParameter.keys)
            } else if let channelParameter = channelToChannelParameters[operation] {
                entries = Array(channelParameter.keys)
            } else {
                entries = []
            }
            
            return entries.sorted()
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
            return Array(dict.keys).sorted()
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
     Return a sparse table of Pan/Balance Parameter values (Int). These tables
     are SPARSE in that they do not contain entries for all values in the input
     range, but MUST contain at least entries for the first and last values in
     the range.
     */
    func panParameterValues() -> [Int: Int] {
        return panBalanceParameters.mapValues { value in
            let bytes = value.split(separator: " ")
            return Values.toParameterNumber(String(bytes[0]), String(bytes[1]))
        }
    }

    /**
     Return a sparse table of Level Parameter values (Int) for the given fader
     law, if that fader loaw is available in the mixer configuraiton. These
     tables are SPARSE in that they do not contain entries for all values in the input
     range, but MUST contain at least entries for the first and last values in
     the range.
     */
    func levelParameterValues(_ taperLaw: FaderLevelLaw) -> [Int: Int]? {
        return levelParameters[taperLaw]?.mapValues { value in
            let bytes = value.split(separator: " ")
            return Values.toParameterNumber(String(bytes[0]), String(bytes[1]))
        }
    }
    
    /**
     Return the list of fader laws supported by the mixer configuration
     */
    func faderLaws() -> [FaderLevelLaw] {
        return levelParameters.keys.sorted()
    }
    
    /**
     Load the configuration for the specified mixer series.
     */
    static func load(_ model: MixerSeries) -> MixerConfig {
        if model == .none {
            return NONE
        }
        
        let settingsUrl = Bundle.main.url(forResource: "\(model)", withExtension: "plist")
        let settingsData = try! Data(contentsOf: settingsUrl!)
        do {
            let decoder = PropertyListDecoder()
            return try decoder.decode(MixerConfig.self, from: settingsData)
        } catch {
            fatalError("Unable to decode \(model).plist")
        }
    }
    
    static func == (lhs: MixerConfig, rhs: MixerConfig) -> Bool {
        return lhs.series == rhs.series
    }
}

/**
 Parameters for Soft Key Actions
 */
public struct SoftKeyParameters: Codable {
    private let noteZero: String
    private let pressVelocity: String
    private let releaseVelocity: String
    
    init() {
        noteZero = ""
        pressVelocity = ""
        releaseVelocity = ""
    }

    func noteZeroParameter() -> Int {
        return noteZero.hex!.value
    }

    func pressVelocityParameter() -> Int {
        return pressVelocity.hex!.value
    }

    func releaseVelocityParameter() -> Int {
        return releaseVelocity.hex!.value
    }
}
