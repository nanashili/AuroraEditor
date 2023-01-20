//
//  SetupEditorClass.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2023/01/09.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

class EditorSetupService: IEditorSetupService {

    private let userDefaults = UserDefaults.standard

    private let firstTimeKey: String = "editorFirstTimeUse"

    /// Returns the value of the first time use. The value returned indicates whether the
    /// user has used the editor before or not.
    func isFirstTimeUse() -> Bool {
        if userDefaults.bool(forKey: firstTimeKey) == false {
            return true
        } else {
            return false
        }
    }

    func updateEditorUsage(value: Bool) {
        userDefaults.set(value, forKey: firstTimeKey)
    }

    func openSetupWindow() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 460, height: 490),
            styleMask: [.titled, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        window.titlebarAppearsTransparent = true
        window.isMovableByWindowBackground = true
        window.center()

        let windowController = NSWindowController(window: window)

        window.contentView = NSHostingView(rootView: AuroraEditorSetupView())
        window.makeKeyAndOrderFront(self)
    }
}
