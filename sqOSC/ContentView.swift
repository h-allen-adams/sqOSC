//
//  ContentView.swift
//  sqOSC
//
//  Created by H Allen Adams on 7/4/24.
//

import SwiftData
import SwiftUI

struct ContentView: View {
    @ObservedObject var handler: SqOscHandler

    var body: some View {
        TextEditor(text: $handler.logText)
    }
}

#Preview {
    ContentView(handler: SqOscHandler { _, _ in })
}
