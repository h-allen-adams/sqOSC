//
//  EndpointDictionary.swift
//  sqOSC
//
//  Created by H Allen Adams on 7/5/24.
//

import Foundation

class EndpointDictionary {
    var entries: [EndpointDictEntryType: EndpointDictEntry]

    init() {
        entries = [
            EndpointDictEntryType.scene:
                EndpointDictEntry(title: "Scene Recall",
                                  paths: [
                                      SqChannelType.none: "/sq/scene/recall",
                                  ]),
            EndpointDictEntryType.keys:
                EndpointDictEntry(title: "SoftKey Control",
                                  paths: [
                                      SqChannelType.none: "/sq/softKey/{keyNum}/trigger",
                                  ]),
            EndpointDictEntryType.mute:
                EndpointDictEntry(title: "Mute Channels",
                                  paths: [
                                      SqChannelType.muteGroup: "/sq/muteGroup/{chNum}/mute",
                                      SqChannelType.dca: "/sq/dca/{chNum}/mute",
                                      SqChannelType.main: "/sq/main/mute",
                                      SqChannelType.aux: "/sq/aux/{chNum}/mute",
                                      SqChannelType.matrix: "/sq/matrix/{chNum}/mute",
                                      SqChannelType.input: "/sq/input/{chNum}/mute",
                                      SqChannelType.fxSend: "/sq/fxSend/{chNum}/mute",
                                      SqChannelType.fxReturn: "/sq/fxReturn/{chNum}/mute",
                                      SqChannelType.group: "/sq/group/{chNum}/mute",
                                  ]),
            EndpointDictEntryType.level:
                EndpointDictEntry(title: "Output Levels",
                                  paths: [
                                      SqChannelType.dca: "/sq/dca/{chNum}/level",
                                      SqChannelType.main: "/sq/main/level",
                                      SqChannelType.aux: "/sq/aux/{chNum}/level",
                                      SqChannelType.matrix: "/sq/matrix/{chNum}/level",
                                      SqChannelType.fxSend: "/sq/fxSend/{chNum}/level",
                                  ]),
            EndpointDictEntryType.sendLevel:
                EndpointDictEntry(title: "Send Levels",
                                  paths: [
                                      SqChannelType.main: "/sq/main/sendLevel",
                                      SqChannelType.aux: "/sq/aux/{chNum}/sendLevel",
                                      SqChannelType.input: "/sq/input/{chNum}/sendLevel",
                                      SqChannelType.fxReturn: "/sq/fxReturn/{chNum}/sendLevel",
                                      SqChannelType.group: "/sq/fxReturn/{chNum}/sendLevel",
                                  ]),
        ]
    }

    func resolvePath(entryType: EndpointDictEntryType, pathType: SqChannelType = SqChannelType.none, pathValues: [String: String] = [:]) -> String? {
        return entries[entryType]?.resolvePath(pathType: pathType, pathValues: pathValues)
    }

    func values() -> [EndpointDictEntry] {
        var result: [EndpointDictEntry] = []
        let sorted = entries.sorted { $0.0.rawValue < $1.0.rawValue }
        for entry in sorted {
            result.append(entry.value)
        }
        return result
    }
}

struct EndpointDictEntry: Hashable, Identifiable {
    let id = UUID()
    let title: String
    let paths: [SqChannelType: String]

    func resolvePath(pathType: SqChannelType, pathValues: [String: String]) -> String? {
        guard let path = paths[pathType] else { return nil }
        var resolvedPath = path
        for (key, value) in pathValues {
            resolvedPath = resolvedPath.replacingOccurrences(of: "{\(key)}", with: value)
        }
        return resolvedPath
    }

    func displayPaths() -> [DisplayPath] {
        var result: [DisplayPath] = []
        let sorted = paths.sorted { $0.1 < $1.1 }

        for entry in sorted {
            result.append(DisplayPath(path: entry.value))
        }
        return result
    }

    struct DisplayPath: Identifiable {
        let id = UUID()
        let path: String
    }
}

enum EndpointDictEntryType: Int {
    case scene = 0
    case keys
    case mute
    case level
    case sendLevel
}
