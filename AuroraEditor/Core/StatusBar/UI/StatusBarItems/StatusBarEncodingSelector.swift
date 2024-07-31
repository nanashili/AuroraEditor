//
//  StatusBarEncodingSelector.swift
//  Aurora Editor
//
//  Created by Lukas Pistrol on 22.03.22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

/// A selector for the encoding of the status bar.
internal struct StatusBarEncodingSelector: View {

    /// The view body.
    internal var body: some View {
        Menu {
            // UTF 8, ASCII, ...
        } label: {
            StatusBarMenuLabel("UTF 8")
        }
        .menuIndicator(.hidden)
        .menuStyle(.borderlessButton)
        .fixedSize()
        .onHover { isHovering($0) }
    }
}
