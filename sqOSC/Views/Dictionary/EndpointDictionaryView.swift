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
    @ObservedObject var dictionary: SqMixerEndpointDictionary

    var body: some View {
        List(dictionary.values) { entry in
            EndpointDictionaryEntryView(entry: entry)
        }
    }
}

extension SqMixerEndpointDictionary {}

#Preview {
    EndpointDictionaryView(dictionary: SqMixerEndpointDictionary.forConfiguration(.sq))
}
