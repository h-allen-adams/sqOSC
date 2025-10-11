//
//  EndpointDictionaryItemView.swift
//  sqOSC
//
//  Created by H Allen Adams on 9/12/25.
//

import SwiftUI

/**
 View to display a single DisplayPath item, and allow the template to be copied
 to the clipboard
 */
struct EndpointDictionaryDisplayPathView: View {
    let len: Int
    let displayPath: EndpointDictEntry.DisplayPath

    var body: some View {
        let formatted = displayPath.path.padding(toLength: len, withPad: " ", startingAt: 0)
        let displayText = "\(formatted)  \(displayPath.parameters)"
        let copyText = "\(displayPath.path) \(displayPath.parameters)"
        HStack(alignment: .top, spacing: 0.0) {
            Button(action: {
                let pasteboard = NSPasteboard.general
                pasteboard.clearContents()
                pasteboard.setString(copyText, forType: .string)
            }) {
                Image(systemName: "doc.on.doc")
            }
            Text(" ")
            Text(displayText)
                .monospaced()
                .textSelection(.enabled)
        }
    }
}

#Preview {
    EndpointDictionaryDisplayPathView(len: 35, displayPath: SqMixerEndpointDictionary(.sq).entries[MixerMethod.sendLevel]!.displayPaths().first!)
}
