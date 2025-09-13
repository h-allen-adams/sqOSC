//
//  MuteBuilderView.swift
//  sqOSC
//
//  Created by H Allen Adams on 9/12/25.
//

import SwiftUI

struct SoftkeyBuilderView: View {
    let dictionary: SqMixerEndpointDictionary
    let operation: EndpointOperationType = .trigger

    @Binding var resolvedPath: String
    @State private var selectedChannelType: EndpointType = EndpointOperationType.trigger.endpoints.first!
    @State private var selectedChannelNum: Int = 1
    @State private var selectedToggle: String = "PRESS"

    var body: some View {
        VStack {
            HStack {
                Picker("SoftKey Num", selection: $selectedChannelNum) {
                    ForEach(Array(1 ... selectedChannelType.count), id: \.self) {
                        Text("\($0)")
                    }
                }
                .pickerStyle(.menu)
                Picker("Toggle", selection: $selectedToggle) {
                    ForEach(["PRESS", "RELEASE"], id: \.self) {
                        Text("\($0)")
                    }
                }
                .pickerStyle(.segmented)
            }
        }
        .onAppear {
            updateResolvedPath()
        }
        .onChange(of: selectedChannelType) { _, _ in
            updateResolvedPath()
        }
        .onChange(of: selectedChannelNum) { _, _ in
            updateResolvedPath()
        }
        .onChange(of: selectedToggle) { _, _ in
            updateResolvedPath()
        }
    }

    func updateResolvedPath() {
        let pathValues = [
            "keyNum": "\(selectedChannelNum)"
        ]
        resolvedPath = dictionary.resolvePath(operation: operation, endpoint: selectedChannelType, pathValues: pathValues)!
            + " \(selectedToggle)"
    }
}

#Preview {
    @Previewable @State var resolvedPath = ""
    SoftkeyBuilderView(dictionary: SqMixerEndpointDictionary(), resolvedPath: $resolvedPath)
}
