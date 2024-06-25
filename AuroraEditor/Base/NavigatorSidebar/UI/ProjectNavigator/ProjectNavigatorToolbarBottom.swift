//
//  ProjectNavigatorToolbarBottom.swift
//  Aurora Editor
//
//  Created by TAY KAI QUAN on 23/7/22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

/// The bottom toolbar of the project navigator.
struct ProjectNavigatorToolbarBottom: View {

    /// The active state of the control.
    @Environment(\.controlActiveState)
    private var activeState

    /// The color scheme.
    @Environment(\.colorScheme)
    private var colorScheme

    /// The workspace document.
    @EnvironmentObject
    var workspace: WorkspaceDocument

    /// The filter string.
    @State
    var filter: String = ""

    /// The view body.
    var body: some View {
        HStack {
            addNewFileButton
                .frame(width: 20)
                .padding(.leading, 10)
            HStack {
                sortButton
                    .padding(.leading, 5)
                TextField("Filter", text: $filter)
                    .textFieldStyle(.plain)
                    .font(.system(size: 12))
                if !filter.isEmpty {
                    clearFilterButton
                        .padding(.trailing, 5)
                }
            }
            .onChange(of: filter, perform: {
                workspace.filter = $0
            })
            .padding(.vertical, 3)
            .background(colorScheme == .dark ? Color(hex: "#FFFFFF").opacity(0.1) : Color(hex: "#808080").opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.gray, lineWidth: 0.5).cornerRadius(6))
            .padding(.trailing, 5)
            .padding(.leading, -8)
        }
        .frame(height: 29, alignment: .center)
        .frame(maxWidth: .infinity)
        .overlay(alignment: .top) {
            Divider()
        }
    }

    /// Add new file button.
    private var addNewFileButton: some View {
        Menu {
            Button("New File...") {
                // TODO: use currently selected file instead of root
                workspace.newFileModel.showSheetWithUrl(url: workspace.newFileModel.outlineViewSelection?.nearestFolder)
            }

            Divider()

            Button("New Folder") {
                guard let folderURL = workspace.fileSystemClient?.folderURL,
                      let root = try? workspace.fileSystemClient?.getFileItem(folderURL.path) else { return }
                // TODO: use currently selected file instead of root
                root.addFolder(folderName: "untitled")
            }
        } label: {
            Image(systemName: "plus")
                .accessibilityLabel(Text("New item"))
        }
        .menuStyle(.borderlessButton)
        .menuIndicator(.hidden)
        .frame(maxWidth: 30)
        .opacity(activeState == .inactive ? 0.45 : 1)
    }

    /// Sort button.
    private var sortButton: some View {
        Menu {
            Button {
                workspace.data.sortFoldersOnTop.toggle()
            } label: {
                Text(workspace.data.sortFoldersOnTop ? "Alphabetically" : "Folders on top")
            }
        } label: {
            Image(systemName: "line.3.horizontal.decrease.circle")
                .accessibilityLabel(Text("Sort"))
        }
        .menuStyle(.borderlessButton)
        .frame(maxWidth: 30)
        .opacity(activeState == .inactive ? 0.45 : 1)
    }

    /// We clear the text and remove the first responder which removes the cursor
    /// when the user clears the filter.
    private var clearFilterButton: some View {
        Button {
            filter = ""
            NSApp.keyWindow?.makeFirstResponder(nil)
        } label: {
            Image(systemName: "xmark.circle.fill")
                .symbolRenderingMode(.hierarchical)
                .accessibilityLabel(Text("Clear"))
        }
        .buttonStyle(.plain)
        .opacity(activeState == .inactive ? 0.45 : 1)
    }
}
