//
//  EndpointDictionaryView.swift
//  sqOSC
//
//  Created by H Allen Adams on 7/5/24.
//

import SwiftUI

struct EndpointDictionaryView: View {
    let dictionary: SqMixerEndpointDictionary

    var body: some View {
        List(dictionary.values()) { entry in
            EndpointDictionaryEntryView(entry: entry)
        }
    }
}

#Preview {
    EndpointDictionaryView(dictionary: SqMixerEndpointDictionary())
}
