//
//  WindowDataStorage.swift
//  Aurora Editor
//
//  Created by TAY KAI QUAN on 30/10/22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

class AuroraDataStorage: ObservableObject {

    var windowController: AuroraEditorWindowController?

    init(windowController: AuroraEditorWindowController? = nil) {
        self.windowController = windowController
    }

    // Navigator settings
    @Published
    var sortFoldersOnTop: Bool = true {
        didSet { update() }
    }

    // Open sheets in the editor
    @Published
    var activeSheet: ActiveSheet? {
        didSet { update() }
    }

    // Git data for the editor
    @Published
    var currentlySelectedBranch: String = "" {
        didSet { update() }
    }
    @Published
    var branchRevision: String = "" {
        didSet { update() }
    }
    @Published
    var commitHash: String = "" {
        didSet { update() }
    }
    @Published
    var branchRevisionDescription: String = "" {
        didSet { update() }
    }

    // Editor information
    @Published
    public var caretPos: CursorLocation = .init(line: 0, column: 0) {
        didSet {
            update()

            ExtensionsManager.shared.sendEvent(
                event: "didMoveCaret",
                parameters: [
                    "row": caretPos.line,
                    "col": caretPos.column
                ]
            )
        }
    }

    @Published
    public var bracketCount: BracketCount = .init(
        roundBracketCount: 0,
        curlyBracketCount: 0,
        squareBracketCount: 0,
        bracketHistory: []
    ) {
        didSet {
            update()

            ExtensionsManager.shared.sendEvent(
                event: "updateBracketCount",
                parameters: [
                    "roundBracketCount": bracketCount.roundBracketCount,
                    "curlyBracketCount": bracketCount.curlyBracketCount,
                    "squareBracketCount": bracketCount.squareBracketCount,
                    "bracketHistory": bracketCount.bracketHistory
                ]
            )
        }

    }
    @Published
    var currentToken: Token? {
        didSet {
            update()
        }
    }

    /// Function that updates the ``AuroraEditorWindowController`` and the ``WorkspaceDocument``.
    /// Views may reference this class via either of them, and therefore both need to be updated in order
    /// to make sure that the command is recieved by all listeners.
    func update() {
        windowController?.objectWillChange.send()
        windowController?.workspace.objectWillChange.send()
    }
}
