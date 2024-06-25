//
//  CodeEditor.swift
//  Aurora Editor
//
//  Created by Manuel M T Chakravarty on 23/08/2020.
//  Copyright © 2023 Aurora Company. All rights reserved.
//
//  SwiftUI 'CodeEditor' view

import SwiftUI

/// SwiftUI code editor based on TextKit.
public struct CodeEditor {

    /// Specification of the editor layout.
    public struct LayoutConfiguration: Equatable {

        /// Show the minimap if possible. (Currently only supported on macOS.)
        public let showMinimap: Bool

        /// Creates a layout configuration.
        ///
        /// - Parameter showMinimap: Whether to show the minimap if possible.\
        /// It may not be possible on all supported OSes.
        public init(showMinimap: Bool) {
            self.showMinimap = showMinimap
        }

        /// Standard layout configuration.
        public static let standard = LayoutConfiguration(showMinimap: true)
    }

    /// Specification of a text editing position; i.e., text selection and scroll position.
    public struct Position: Equatable {

        /// Specification of a list of selection ranges.
        ///
        /// * A range with a zero length indicates an insertion point.
        /// * An empty array, corresponds to an insertion point at position 0.
        /// * On iOS, this can only always be one range.
        public var selections: [NSRange]

        /// The editor vertical scroll position. The value is between 0 and 1,
        /// which represent the completely scrolled up and down position, respectively.
        public var verticalScrollFraction: CGFloat

        /// Creates a text editing position.
        /// 
        /// - Parameter selections: The selection ranges.
        /// - Parameter verticalScrollFraction: The vertical scroll position.
        public init(selections: [NSRange], verticalScrollFraction: CGFloat) {
            self.selections = selections
            self.verticalScrollFraction = verticalScrollFraction
        }

        /// Creates a text editing position with an empty selection at the beginning of the text.
        public init() {
            self.init(selections: [NSRange(location: 0, length: 0)], verticalScrollFraction: 0)
        }
    }

    /// Layout configuration.
    let layout: LayoutConfiguration

    /// Text to edit.
    @Binding
    var text: String

    /// Current edit position.
    @Binding
    var position: Position

    /// Current caret position.
    @Binding
    var caretPosition: CursorLocation

    /// Current bracket count.
    @Binding
    var bracketCount: BracketCount

    /// Current token.
    @Binding
    var currentToken: Token?

    /// Messages reported at the appropriate lines of the edited text.
    @Binding
    var messages: Set<Located<Message>>

    /// Theme for syntax highlighting.
    @Binding
    var theme: AuroraTheme

    /// File extension for syntax highlighting.
    @Binding
    var fileExtension: String

    /// Creates a fully configured code editor.
    ///
    /// - Parameters:
    ///   - text: Binding to the edited text.
    ///   - position: Binding to the current edit position.
    ///   - messages: Binding to the messages reported at the appropriate lines of the edited text. NB: Messages
    ///               processing and display is relatively expensive. Hence, there should only be a limited number of
    ///               simultaneous messages and they shouldn't change to frequently.
    ///   - language: Language configuration for highlighting and similar.
    ///   - layout: Layout configuration determining the visible elements of the editor view.
    public init(text: Binding<String>,
                position: Binding<Position>,
                caretPosition: Binding<CursorLocation>,
                bracketCount: Binding<BracketCount>,
                currentToken: Binding<Token?>,
                messages: Binding<Set<Located<Message>>>,
                theme: Binding<AuroraTheme>,
                fileExtension: Binding<String>,
                layout: LayoutConfiguration = .standard
    ) {
        self._text = text
        self._position = position
        self._caretPosition = caretPosition
        self._bracketCount = bracketCount
        self._currentToken = currentToken
        self._messages = messages
        self._theme = theme
        self._fileExtension = fileExtension
        self.layout = layout
    }

    /// Text Coordinator
    public class TCoordinator {
        /// Text
        @Binding
        var text: String

        /// Position
        @Binding
        var position: Position

        /// Caret position
        @Binding
        var caretPosition: CursorLocation

        /// Bracket count
        @Binding
        var bracketCount: BracketCount

        /// Current token
        @Binding
        var currentToken: Token?

        /// In order to avoid update cycles, where view code tries to update SwiftUI state variables (such as the view's
        /// bindings) during a SwiftUI view update, we use `updatingView` as a flag that indicates whether the view is
        /// being updated, and hence, whether state updates ought to be avoided or delayed.
        public var updatingView = false

        /// This is the last observed value of `messages`, to enable us to compute the difference in the next update.
        public var lastMessages: Set<Located<Message>> = Set()

        /// The text storage that holds the text to be edited.
        /// 
        /// - Parameter text: The text to be edited.
        /// - Parameter position: The current edit position.
        /// - Parameter caretPosition: The current caret position.
        /// - Parameter bracketCount: The current bracket count.
        /// - Parameter currentToken: The current token.
        init(_ text: Binding<String>,
             _ position: Binding<Position>,
             _ caretPosition: Binding<CursorLocation>,
             _ bracketCount: Binding<BracketCount>,
             _ currentToken: Binding<Token?>
        ) {
            self._text = text
            self._position = position
            self._caretPosition = caretPosition
            self._bracketCount = bracketCount
            self._currentToken = currentToken
        }
    }
}
