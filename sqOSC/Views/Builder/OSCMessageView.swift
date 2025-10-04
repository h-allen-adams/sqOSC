//
//  OSCMessageView.swift
//  sqOSC
//
//  Created by H Allen Adams on 9/12/25.
//

import OSCKitCore
import SwiftUI

/**
 Display a message constructed by builder views and provide options to copy the
 message to the clipboard, and send the corresponding MIDI message to the mixer.
 */
struct OSCMessageView: View {
    @Binding var resolvedMessage: String
    @EnvironmentObject private var messageSender: OscMessageSender

    var body: some View {
        HStack(alignment: .top, spacing: 0.0) {
            Button(action: {
                let pasteboard = NSPasteboard.general
                pasteboard.clearContents()
                pasteboard.setString(resolvedMessage, forType: .string)
            }) {
                Image(systemName: "doc.on.doc")
            }.help("Copy to Clipboard")
            Button(action: {
                messageSender.callEndpoint(resolvedMessage)
            }) {
                Image(systemName: "paperplane")
            }.help("Send Message")
            Text(" ")
            Text(resolvedMessage)
                .monospaced()
                .textSelection(.enabled)
        }
    }
}

#Preview {
    @Previewable @State var resolvedMessage = "/sq/some/resolvedPath 125"
    OSCMessageView(resolvedMessage: $resolvedMessage)
        .environmentObject(OscMessageSender(addressSpace: nil))
}
