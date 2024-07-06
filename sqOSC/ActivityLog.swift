//
//  ActivityLog.swift
//  sqOSC
//
//  Created by H Allen Adams on 7/6/24.
//

import Foundation

class ActivityLog: ObservableObject {
    @Published var logText = ""

    func logMessage(logText: String) {
        self.logText.append(logText)
    }
}
