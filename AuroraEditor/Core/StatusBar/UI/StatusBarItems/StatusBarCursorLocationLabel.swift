//
//  StatusBarCursorLocationLabel.swift
//  Aurora Editor
//
//  Created by Lukas Pistrol on 22.03.22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

/// A label that shows the current cursor location.
internal struct StatusBarCursorLocationLabel: View {

    /// The active state of the control.
    @Environment(\.controlActiveState)
    private var controlActive

    /// The workspace document.
    @EnvironmentObject
    private var workspace: WorkspaceDocument

    /// The view body.
    internal var body: some View {
        Text("Ln: \(workspace.data.caretPos.line)  Col: \(workspace.data.caretPos.column)")
            .font(.system(size: 11))
            .foregroundColor(.secondary)
            .fixedSize()
            .lineLimit(1)
            .onHover { isHovering($0) }
    }

    /// The foreground color of the label.
    private var foregroundColor: Color {
        controlActive == .inactive ? Color(nsColor: .disabledControlTextColor) : .primary
    }
}
