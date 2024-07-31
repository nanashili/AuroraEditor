//
//  StatusBarFloatingView.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 7/31/24.
//  Copyright © 2024 Aurora Company. All rights reserved.
//

import SwiftUI

struct StatusBarFloatingView: View {
    @EnvironmentObject var workspace: WorkspaceDocument
    @ObservedObject private var prefs: AppPreferencesModel = .shared
    @State private var hideTimer: Timer?
    @State private var isVisible: Bool = true

    var body: some View {
        VStack {
            if isVisible {
                HStack {
                    if let selectedId = workspace.selectionState.selectedId,
                       selectedId.id.contains("codeEditor_") {
                        StatusBarCursorLocationLabel()
                        StatusBarIndentSelector()
                        StatusBarLineEndSelector()
                    }
                }
            } else {
                Image(systemName: "info.circle")
                    .accessibilityLabel("")
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(.bar)
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 3)
        .padding([.bottom, .trailing], 15)
        .onHover(perform: { hovering in
            if hovering && !isVisible {
                withAnimation {
                    isVisible = true
                    startHideTimer()
                }
            }
        })
        .onAppear {
            if prefs.preferences.textEditing.hideFloatingStatusBarAfter != 0 {
                startHideTimer()
            }
        }
    }

    private func startHideTimer() {
        hideTimer?.invalidate()
        hideTimer = Timer.scheduledTimer(
            withTimeInterval: TimeInterval(
                prefs.preferences.textEditing.hideFloatingStatusBarAfter
            ),
            repeats: false
        ) { _ in
            withAnimation {
                self.isVisible = false
            }
        }
    }
}
