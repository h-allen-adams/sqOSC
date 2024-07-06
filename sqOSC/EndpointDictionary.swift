//
//  EndpointDictionary.swift
//  sqOSC
//
//  Created by H Allen Adams on 7/5/24.
//

import Foundation

class EndpointDictionary: ObservableObject {
    var entries: [EndpointDictEntry]

    init() {
        entries = []
    }

    init(entries: [EndpointDictEntry]) {
        self.entries = entries
    }
}

struct EndpointDictEntry: Hashable, Identifiable {
    let id = UUID()
    var path: String
    var children: [EndpointDictEntry]?

    init(path: String) {
        self.path = path
        children = []
    }

    init(path: String, children: [EndpointDictEntry]) {
        self.path = path
        self.children = children
    }

    mutating func addChild(childName: String) -> EndpointDictEntry {
        let entry = EndpointDictEntry(path: "\(path)/\(childName)")
        children!.append(entry)
        return children!.last!
    }

    func resolvePath(pathValues: [String: String]) -> String {
        var resolvedPath = path
        for (key, value) in pathValues {
            resolvedPath = resolvedPath.replacingOccurrences(of: "{\(key)}", with: value)
        }
        return resolvedPath
    }
}
