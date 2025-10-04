//
//  EndpointDictionaryView.swift
//  sqOSC
//
//  Created by H Allen Adams on 7/5/24.
//

import SwiftUI

/**
 The Dictionary view displays the OSC address templates defined by an
 SqMixerEndpointDictioanry
 */
struct EndpointDictionaryView: View {
    let dictionary: SqMixerEndpointDictionary

    var body: some View {
        List(dictionary.values()) { entry in
            EndpointDictionaryEntryView(entry: entry)
        }
    }
}

extension SqMixerEndpointDictionary {
    /**
     Return a sorted list of EndpointDictEntry items for UI display
     */
    func values() -> [EndpointDictEntry] {
        var result: [EndpointDictEntry] = []
        let allCases = MixerMethod.allCases
        let sorted = entries.sorted { allCases.firstIndex(of: $0.key)! < allCases.firstIndex(of: $1.key)! }
        for entry in sorted {
            result.append(entry.value)
        }
        return result
    }
}

#Preview {
    EndpointDictionaryView(dictionary: SqMixerEndpointDictionary())
}
