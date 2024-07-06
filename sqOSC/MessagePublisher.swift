//
//  MessagePublisher.swift
//  sqOSC
//
//  Created by H Allen Adams on 7/5/24.
//

import Foundation
import MIDIKitCore

typealias MessagePublisher = (_ label: String, _ message: MIDIEvent) -> Void
