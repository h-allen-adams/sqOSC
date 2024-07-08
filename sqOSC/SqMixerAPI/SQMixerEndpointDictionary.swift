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
            result.append(DisplayPath(path: entry.value, parameters: operation.parameters(endpoint: entry.key)))
        }
        return result
    }

    struct DisplayPath: Identifiable {
        let id = UUID()
        let path: String
        let parameters: String
    }

    static func pathsFor(operation: EndpointOperationType) -> [EndpointType: String] {
        return operation.endpoints.reduce(into: [:]) {
            $0[$1] = "\($1.basePath())/\(operation)"
        }
    }
}
