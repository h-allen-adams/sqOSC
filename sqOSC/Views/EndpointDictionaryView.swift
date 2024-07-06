//
//  EndpointDictionaryView.swift
//  sqOSC
//
//  Created by H Allen Adams on 7/5/24.
//

import SwiftUI

struct EndpointDictionaryView: View {
    @ObservedObject var dictionary: EndpointDictionary

    var body: some View {
        List($dictionary.entries, children: \.children) {
            Text($0.wrappedValue.path).font(.subheadline)
        }
    }
}

#Preview {
    EndpointDictionaryView(dictionary: EndpointDictionary(entries: EndpointDictEntry.stubs))
}

extension EndpointDictEntry {
    static var stubs: [EndpointDictEntry] {
        [
            EndpointDictEntry(path: "/sq/input", children: [EndpointDictEntry(path: "/sq/input/{n}/mute")]),
            EndpointDictEntry(path: "/sq/main")
        ]
    }
}
