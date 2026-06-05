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
    @Binding var resolvedEvent: AttributedString
    @EnvironmentObject private var messageSender: OscMessageSender

    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .center, spacing: 0.0) {
                Button(action: {
                    let pasteboard = NSPasteboard.general
                    pasteboard.clearContents()
                    pasteboard.setString(resolvedMessage, forType: .string)
                }) {
                    Image(systemName: "doc.on.doc")
                        .frame(height: 20)
                }.help("Copy to Clipboard")
                Button(action: {
                    messageSender.callEndpoint(resolvedMessage)
                }) {
                    Image(systemName: "paperplane")
                        .frame(height: 20)
                }
                .help("Send Message")
                Text(" ")
                Text(resolvedMessage)
                    .monospaced()
                    .textSelection(.enabled)
            }
            HStack(alignment: .top, spacing: 0.0) {
                Text("           ").monospaced()
                Text(resolvedEvent)
                    .monospaced()
                    .textSelection(.enabled)
            }
        }
    }
}

#Preview {
    @Previewable @State var resolvedEvent = AttributedString("01 02 03 04 05 06 07 08 09 10 11 12")
    @Previewable @State var resolvedMessage = "/sq/some/resolvedPath 125"
    OSCMessageView(resolvedMessage: $resolvedMessage, resolvedEvent: $resolvedEvent)
        .environmentObject(OscMessageSender(addressSpace: nil))
}
