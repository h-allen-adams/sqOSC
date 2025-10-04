//
//  EndpointDictionaryEntryView.swift
//  sqOSC
//
//  Created by H Allen Adams on 7/5/24.
//

import SwiftUI

/**
 Display the path templates defined in an EndpointDictEntry
 */
struct EndpointDictionaryEntryView: View {
    let entry: EndpointDictEntry

    var len: Int {
        var count = 0
        entry.displayPaths().forEach { displayPath in
            count = max(count, displayPath.path.count)
        }
        return count
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 1) {
            Section(header: Text(entry.operation.title).font(.title3)) {
                ForEach(entry.displayPaths()) { displayPath in
                    EndpointDictionaryDisplayPathView(len: len, displayPath: displayPath)
                }
            }
        }
    }
}

extension EndpointDictEntry {
    /**
     Return a sorted list of DisplayPath items for display
     */
    func displayPaths() -> [DisplayPath] {
        var result: [DisplayPath] = []
        let sorted = addressTemplates.sorted { $0.1 < $1.1 }

        for entry in sorted {
            let parameters = EndpointDictEntry.oscArgumentTemplates[operation] ?? ""
            result.append(DisplayPath(path: entry.value,
                                      parameters: parameters))
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
}

#Preview {
    EndpointDictionaryEntryView(entry: SqMixerEndpointDictionary().entries[MixerMethod.sendLevel]!)
}
