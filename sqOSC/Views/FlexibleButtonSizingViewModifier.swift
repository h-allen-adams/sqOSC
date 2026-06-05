//
//  FlexibleButtonSizingViewModifier.swift
//  sqOSC
//
//  Created by H Allen Adams on 6/5/26.
//

import SwiftUI

struct FlexibleButtonSizingModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(macOS 26, *) {
            content.buttonSizing(.flexible)
        } else {
            content // no-op on older macOS
        }
    }
}

extension View {
    @ViewBuilder
    func flexibleButtonSizing() -> some View {
        modifier(FlexibleButtonSizingModifier())
    }
}
