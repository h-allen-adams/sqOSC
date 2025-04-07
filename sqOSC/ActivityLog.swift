//
//  ActivityLog.swift
//  sqOSC
//
//  Created by H Allen Adams on 7/6/24.
//

import Foundation

class ActivityLog: ObservableObject {
    @Published var logText = ""

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        return formatter
    }()

    func logMessage(logText: String) {
        var textToInsert = self.dateFormatter.string(from: Date())
        textToInsert.append(": ")
        textToInsert.append(logText)
        textToInsert.append("\n")
        DispatchQueue.main.async {
            self.logText.insert(contentsOf: textToInsert, at: self.logText.startIndex)
        }
    }
}
