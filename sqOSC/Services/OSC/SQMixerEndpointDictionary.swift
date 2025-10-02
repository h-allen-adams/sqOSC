//
//  EndpointDictionary.swift
//  sqOSC
//
//  Created by H Allen Adams on 7/5/24.
//

import Foundation

/**
 Define the OSC Address template dictionary for the mixer based on the data in
 the SqMixerConfig singleton. Once initialized, the dictionary is used for
 display on the "Dictionary" tab of the UI and to initialize the OSC Service
 with the proper addresses. The OSC message dictionary defines path templates
 which will undergo variable substitution to form OSC addresses.
 */
class SqMixerEndpointDictionary: ObservableObject {
    let mixerConfig = SqMixerConfig.singletonInstance()

    var entries: [EndpointOperationType: EndpointDictEntry]

    /**
     Create a dictionary where each key are EndpointOperationType's and the
     associated value is the EndpointDictEntry for that operation.
     */
    init() {
        entries = EndpointOperationType.allCases.reduce(into: [:]) { $0[$1] = EndpointDictEntry(operation: $1) }
    }

    /**
     Resolve a path for the given operation and endpoint, substituting the
     values in the path values dictionary into the path template.
     */
    func resolvePath(operation: EndpointOperationType, endpoint: EndpointType, pathValues: [String: String] = [:]) -> String? {
        return entries[operation]?.resolvePath(pathType: endpoint, pathValues: pathValues)
    }

    /**
     Return a sorted list of EndpointDictEntry items for UI display
     */
    func values() -> [EndpointDictEntry] {
        var result: [EndpointDictEntry] = []
        let sorted = entries.sorted { $0.0.rawValue < $1.0.rawValue }
        for entry in sorted {
            result.append(entry.value)
        }
        return result
    }
}

/**
 OSC Address Termplate Dictionary entry for a single operation type.
 */
struct EndpointDictEntry: Hashable, Identifiable {
    let id = UUID()
    let operation: EndpointOperationType
    let paths: [EndpointType: String]

    init(operation: EndpointOperationType) {
        self.operation = operation
        paths = Self.pathsFor(operation: operation)
    }

    /**
     Return the huma-readable title for the entry
     */
    public var title: String {
        return operation.title
    }

    /**
     Resolve a path for the given endpoint typem substituting the values in the
     path values dictionary into the path template.
     */
    func resolvePath(pathType: EndpointType, pathValues: [String: String]) -> String? {
        guard let path = paths[pathType] else { return nil }
        var resolvedPath = path
        for (key, value) in pathValues {
            resolvedPath = resolvedPath.replacingOccurrences(of: "{\(key)}", with: value)
        }
        return resolvedPath
    }

    /**
     Return a sorted list of DisplayPath items for display
     */
    func displayPaths() -> [DisplayPath] {
        var result: [DisplayPath] = []
        let sorted = paths.sorted { $0.1 < $1.1 }

        for entry in sorted {
            result.append(DisplayPath(path: entry.value, parameters: operation.parameters()))
        }
        return result
    }

    /**
     Data to display a path template and the set of parameter arguments it
     supports.
     */
    struct DisplayPath: Identifiable {
        let id = UUID()
        let path: String
        let parameters: String
    }

    /**
     Base path templates for each operation.
     */
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

    /**
     Return a dictionary of path templates for the given operation. Each
     endpoint type supported by the operation will be a key in the result
     dictionary with a value of the path template.
     */
    static func pathsFor(operation: EndpointOperationType) -> [EndpointType: String] {
        let mixerConfig = SqMixerConfig.singletonInstance()
        if operation == .sendLevel || operation == .pan {
            // Path templates for operations with targets need a "{dest}" template
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
