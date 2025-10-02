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
            Section(header: Text(entry.title).font(.title3)) {
                ForEach(entry.displayPaths()) { displayPath in
                    EndpointDictionaryDisplayPathView(len: len, displayPath: displayPath)
                }
            }
        }
    }
}

#Preview {
    EndpointDictionaryEntryView(entry: SqMixerEndpointDictionary().entries[EndpointOperationType.sendLevel]!)
}
