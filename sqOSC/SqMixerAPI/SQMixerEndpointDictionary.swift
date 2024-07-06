//
//  EndpointDictionary.swift
//  sqOSC
//
//  Created by H Allen Adams on 7/5/24.
//

import Foundation

class SqMixerEndpointDictionary: ObservableObject {
    var entries: [EndpointOperationType: EndpointDictEntry]

    init() {
        entries = [
            EndpointOperationType.recall:
                EndpointDictEntry(title: "Scene Recall",
                                  paths: SqMixerEndpointDictionary.pathsFor(operation: EndpointOperationType.recall)),
            EndpointOperationType.trigger:
                EndpointDictEntry(title: "SoftKey Control",
                                  paths: SqMixerEndpointDictionary.pathsFor(operation: EndpointOperationType.trigger)),
            EndpointOperationType.mute:
                EndpointDictEntry(title: "Mute Channels",
                                  paths: SqMixerEndpointDictionary.pathsFor(operation: EndpointOperationType.mute)),
            EndpointOperationType.level:
                EndpointDictEntry(title: "Output Levels",
                                  paths: SqMixerEndpointDictionary.pathsFor(operation: EndpointOperationType.level)),
            EndpointOperationType.sendLevel:
                EndpointDictEntry(title: "Send Levels",
                                  paths: SqMixerEndpointDictionary.pathsFor(operation: EndpointOperationType.sendLevel)),
        ]
    }

    func resolvePath(entryType: EndpointOperationType, pathType: EndpointType, pathValues: [String: String] = [:]) -> String? {
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

    static func pathsFor(operation: EndpointOperationType) -> [EndpointType: String] {
        return operation.endpoints().reduce(into: [:]) {
            $0[$1] = "\($1.basePath())/\(operation)"
        }
    }
}

struct EndpointDictEntry: Hashable, Identifiable {
    let id = UUID()
    let title: String
    let paths: [EndpointType: String]

    func resolvePath(pathType: EndpointType, pathValues: [String: String]) -> String? {
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
