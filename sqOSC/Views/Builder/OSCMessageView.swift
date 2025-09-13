//
//  OSCMessageView.swift
//  sqOSC
//
//  Created by H Allen Adams on 9/12/25.
//

import OSCKitCore
import SwiftUI

struct OSCMessageView: View {
    @Binding var resolvedPath: String
    @EnvironmentObject private var addressSpace: OscMessageSender

    var body: some View {
        HStack(alignment: .top, spacing: 0.0) {
            Button(action: {
                let pasteboard = NSPasteboard.general
                pasteboard.clearContents()
                pasteboard.setString(resolvedPath, forType: .string)
            }) {
                Image(systemName: "doc.on.doc")
            }.help("Copy to Clipboard")
            Button(action: {
                addressSpace.callEndpoint(resolvedPath)
            }) {
                Image(systemName: "paperplane")
            }.help("Send Message")
            Text(" ")
            Text(resolvedPath)
                .monospaced()
                .textSelection(.enabled)
        }
    }
}

#Preview {
    @Previewable @State var resolvedPath = "/sq/some/resolvedPath 125"
    OSCMessageView(resolvedPath: $resolvedPath).environmentObject(OscMessageSender(addressSpace: nil))
}
