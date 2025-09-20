//
//  EndpointDictionary.swift
//  sqOSC
//
//  Created by H Allen Adams on 7/5/24.
//

import Foundation

class SqMixerEndpointDictionary: ObservableObject {
    let mixerConfig = SqMixerConfig.singletonInstance()

    var entries: [EndpointOperationType: EndpointDictEntry]

    init() {
        entries = EndpointOperationType.allCases.reduce(into: [:]) { $0[$1] = EndpointDictEntry(operation: $1) }
    }

    func resolvePath(operation: EndpointOperationType, endpoint: EndpointType, pathValues: [String: String] = [:]) -> String? {
        return entries[operation]?.resolvePath(pathType: endpoint, pathValues: pathValues)
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
    let operation: EndpointOperationType
    let paths: [EndpointType: String]

    init(operation: EndpointOperationType) {
        self.operation = operation
        paths = Self.pathsFor(operation: operation)
    }

    public var title: String {
        return operation.title
    }

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
            result.append(DisplayPath(path: entry.value, parameters: operation.parameters()))
        }
        return result
    }

    struct DisplayPath: Identifiable {
        let id = UUID()
        let path: String
        let parameters: String
    }

    static let basePaths = [
        EndpointType.aux: "/sq/aux/{chNum}",
        EndpointType.dca: "/sq/dca/{chNum}",
        EndpointType.fxReturn: "/sq/fxReturn/{chNum}",
        EndpointType.fxSend: "/sq/fxSend/{chNum}",
        EndpointType.group: "/sq/group/{chNum}",
        EndpointType.input: "/sq/input/{chNum}",
        EndpointType.keys: "/sq/softKey/{keyNum}",
        EndpointType.main: "/sq/main",
        EndpointType.matrix: "/sq/matrix/{chNum}",
        EndpointType.muteGroup: "/sq/muteGroup/{chNum}",
        EndpointType.scene: "/sq/scene"
    ]

    static func pathsFor(operation: EndpointOperationType) -> [EndpointType: String] {
        let mixerConfig = SqMixerConfig.singletonInstance()
        if operation == .sendLevel || operation == .pan {
            return mixerConfig.channelsFor(operation).reduce(into: [:]) {
                $0[$1] = "\(basePaths[$1]!)/\(operation)/{dest}"
            }
        } else {
            return mixerConfig.channelsFor(operation).reduce(into: [:]) {
                $0[$1] = "\(basePaths[$1]!)/\(operation)"
            }
        }
    }
}
