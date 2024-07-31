//
//  TextEditingPreferencesView.swift
//  Aurora Editor
//
//  Created by Lukas Pistrol on 30.03.22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

/// A view that implements the `Text Editing` preference section
public struct TextEditingPreferencesView: View {
    /// The preferences model
    @StateObject
    private var prefs: AppPreferencesModel = .shared

    /// Initializes the text editing preferences view
    public init() {}

    /// only allows integer values in the range of `[1...8]`
    private var numberFormat: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.allowsFloats = false
        formatter.minimum = 1
        formatter.maximum = 8

        return formatter
    }

    /// The view body
    public var body: some View {
        PreferencesContent {
            GroupBox {
                floatingStatusBar()
                    .padding(.horizontal)

                Divider()

                if prefs.preferences.textEditing.showFloatingStatusBar {
                    hideFloatingStatusBarAfter()
                        .padding(.horizontal)
                    Divider()
                }

                HStack {
                    Text("settings.text.editing.tab.width")
                    Spacer()
                    HStack(spacing: 5) {
                        TextField("", value: $prefs.preferences.textEditing.defaultTabWidth, formatter: numberFormat)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 40)
                        Stepper("",
                                value: $prefs.preferences.textEditing.defaultTabWidth,
                                in: 1...8)
                        .labelsHidden()
                        Text("spaces")
                    }
                }
                .padding(.horizontal)

                Divider()

                fontSelector
                    .padding(.horizontal)

                Divider()

                scopes
                    .padding(.bottom, 5)
                    .padding(.horizontal)

                Divider()

                disableSyntaxHighlighting
                    .padding(.bottom, 5)
                    .padding(.horizontal)
            }
            .padding(.bottom)

            Text("settings.text.editing.completion")
                .fontWeight(.bold)
                .padding(.horizontal)

            GroupBox {
                autocompleteBraces
                    .padding(.horizontal)
                Divider()
                enableTypeOverCompletion
                    .padding(.horizontal)
            }
        }
    }

    private func floatingStatusBar() -> some View {
        HStack {
            Text("Show Floating Status Bar")
            Spacer()
            Toggle("", isOn: $prefs.preferences.textEditing.showFloatingStatusBar)
                .toggleStyle(.switch)
                .labelsHidden()
        }
    }

    private func hideFloatingStatusBarAfter() -> some View {
        HStack {
            Text("Hide Floating Status Bar After (seconds):")
            Spacer()
            Picker(
                "",
                selection: $prefs.preferences.textEditing.hideFloatingStatusBarAfter
            ) {
                ForEach(
                    Array(
                        stride(
                            from: 10,
                            through: 60,
                            by: 10
                        )
                    ),
                    id: \.self
                ) { second in
                    Text("\(second) sec").tag(second)
                }
                Text("Never").tag(0)
            }
            .pickerStyle(.automatic)
            .frame(maxWidth: 100)
        }
    }

    /// The font selector
    @ViewBuilder
    private var fontSelector: some View {
        HStack {
            Text("settings.global.font")
            Spacer()
            Picker("", selection: $prefs.preferences.editorFont.customFont) {
                Text("settings.global.font.system")
                    .tag(false)
                Text("settings.global.font.custom")
                    .tag(true)
            }
            .labelsHidden()
            .fixedSize()
            if prefs.preferences.editorFont.customFont {
                FontPicker(
                    "\(prefs.preferences.editorFont.name) \(prefs.preferences.editorFont.size)",
                    name: $prefs.preferences.editorFont.name, size: $prefs.preferences.editorFont.size
                )
            }
        }
    }

    /// The scopes toggle
    private var scopes: some View {
        HStack {
            Text("settings.text.editing.show.scopes")
            Spacer()
            Toggle("", isOn: $prefs.preferences.textEditing.showScopes)
                .toggleStyle(.switch)
                .labelsHidden()
        }
    }

    /// The scopes toggle
    private var disableSyntaxHighlighting: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Disable Syntax Highlighting")
                Spacer()
                Toggle("", isOn: $prefs.preferences.textEditing.isSyntaxHighlightingDisabled)
                    .toggleStyle(.switch)
                    .labelsHidden()
            }
            Text("Disabling syntax highlighting can improve performance by reducing the processing required to render the text editor, especially for large files.") // swiftlint:disable:this line_length
                .font(.footnote)
                .foregroundColor(.gray)
        }
    }

    /// The autocomplete braces toggle
    private var autocompleteBraces: some View {
        HStack {
            Text("settings.text.editing.autocomplete.braces")
            Spacer()
            Toggle("", isOn: $prefs.preferences.textEditing.autocompleteBraces)
                .toggleStyle(.switch)
                .labelsHidden()
        }
    }

    /// The enable type over completion toggle
    private var enableTypeOverCompletion: some View {
        HStack {
            Text("settings.text.editing.type.over.completion")
            Spacer()
            Toggle("", isOn: $prefs.preferences.textEditing.enableTypeOverCompletion)
                .toggleStyle(.switch)
                .labelsHidden()
        }
    }
}

struct TextEditingPreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        TextEditingPreferencesView()
    }
}
