//
//  TabBarItemCloseButton.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2024/05/30.
//  Copyright © 2024 Aurora Company. All rights reserved.
//

import SwiftUI

struct TabBarItemCloseButton: View {
    var closeAction: () -> Void
    var isActive: Bool
    var colorScheme: ColorScheme
    var prefs: AppPreferencesModel
    var isHovering: Bool

    @State private var isHoveringCloseState = false
    @State private var isPressingCloseState = false
    @EnvironmentObject private var workspace: WorkspaceDocument

    var body: some View {
        Button(action: {
            if NSEvent.modifierFlags.contains(.option) {
                guard let hoveredTabID = workspace.hoveredTabId else { return }
                workspace.closeAllExceptHoveredTab(hoveredTabID: hoveredTabID)
            } else {
                closeAction()
            }
        }) {
            if prefs.preferences.general.tabBarStyle == .xcode {
                Image(systemName: "xmark")
                    .font(.system(size: 11.2, weight: .regular, design: .rounded))
                    .frame(width: 16, height: 16)
                    .foregroundColor(
                        isActive
                        ? (
                            colorScheme == .dark
                            ? .primary
                            : Color(nsColor: .controlAccentColor)
                        )
                        : .secondary.opacity(0.80)
                    )
            } else {
                Image(systemName: "xmark")
                    .font(.system(size: 9.5, weight: .medium, design: .rounded))
                    .frame(width: 16, height: 16)
            }
        }
        .buttonStyle(.borderless)
        .foregroundColor(isPressingCloseState ? .primary : .secondary)
        .background(
            colorScheme == .dark
            ? Color(nsColor: .white)
                .opacity(isPressingCloseState ? 0.32 : isHoveringCloseState ? 0.18 : 0)
            : (
                prefs.preferences.general.tabBarStyle == .xcode
                ? Color(nsColor: isActive ? .controlAccentColor : .black)
                    .opacity(
                        isPressingCloseState
                        ? 0.25
                        : (isHoveringCloseState ? (isActive ? 0.10 : 0.06) : 0)
                    )
                : Color(nsColor: .black)
                    .opacity(isPressingCloseState ? 0.29 : (isHoveringCloseState ? 0.11 : 0))
            )
        )
        .cornerRadius(2)
        .accessibilityLabel(Text("Close"))
        .onHover { hover in
            isHoveringCloseState = hover
        }
        .pressAction {
            isPressingCloseState = true
        } onRelease: {
            isPressingCloseState = false
        }
        .opacity(isHovering ? 1 : 0)
        .animation(.easeInOut(duration: 0.08), value: isHoveringCloseState)
        .padding(.leading, prefs.preferences.general.tabBarStyle == .xcode ? 3.5 : 4)
    }
}
