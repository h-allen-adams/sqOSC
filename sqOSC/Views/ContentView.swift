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
    enum Tabs: Equatable, Hashable {
        case log
    }

    var body: some View {
        TabView(selection: /*@START_MENU_TOKEN@*/ .constant(1)/*@END_MENU_TOKEN@*/,
                content: {
                    Text("Tab Content 1").tabItem { Text("Configuration") }.tag(1)
                    OutlineGroup($handler.dictionary.root) { entry in
                        Text(entry.$value).font(.subheadline)
                    }.tabItem { Text("Dictionary") }.tag(1)
                    TextEditor(text: $handler.logText).tabItem { Text("Activity Log") }.tag(2)
                })
    }
}

#Preview {
    ContentView(handler: SqOscHandler { _, _ in })
}
