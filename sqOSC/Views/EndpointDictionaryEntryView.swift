//
//  EndpointDictionaryEntryView.swift
//  sqOSC
//
//  Created by H Allen Adams on 7/5/24.
//

import SwiftUI

struct EndpointDictionaryEntryView: View {
    let entry: EndpointDictEntry

    var body: some View {
        VStack(alignment: .leading) {
            Section(header: Text(entry.title).font(.title3)) {
                ForEach(entry.displayPaths()) { displayPath in
                    Text("\(displayPath.path) \t\(displayPath.parameters)")
                }
            }
        }
    }
}

#Preview {
    EndpointDictionaryEntryView(entry: SqMixerEndpointDictionary().entries[EndpointOperationType.mute]!)
}
