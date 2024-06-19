//
//  WorkspaceCodeFileEditor.swift
//  Aurora Editor
//
//  Created by Pavel Kasila on 20.03.22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI
import UniformTypeIdentifiers

struct WorkspaceCodeFileView: View {

    @EnvironmentObject var workspace: WorkspaceDocument
    @StateObject private var prefs: AppPreferencesModel = .shared
    @State private var dropProposal: SplitViewProposalDropPosition?

    /// The font
    @State
    private var font: NSFont = {
        let size = AppPreferencesModel.shared.preferences.textEditing.font.size
        let name = AppPreferencesModel.shared.preferences.textEditing.font.name
        return NSFont(name: name, size: Double(size)) ?? NSFont.monospacedSystemFont(ofSize: 12, weight: .regular)
    }()

    // private var font: NSFont {
    //     let size = AppPreferencesModel.shared.preferences.textEditing.font.size
    //     let name = AppPreferencesModel.shared.preferences.textEditing.font.name
    //     return NSFont(name: name, size: Double(size)) ?? NSFont.monospacedSystemFont(ofSize: 12, weight: .regular)
    // }

    @ViewBuilder
    var codeView: some View {
        ZStack {
            if let selectedItem = workspace.selectionState.openFileItems.first(where: {
                $0.tabID == workspace.selectionState.selectedId
                }),
               let fileItem = workspace.selectionState.openedCodeFiles[selectedItem] {

                switch fileItem.typeOfFile {
                case .image:
                    imageFileView(fileItem, for: selectedItem)
                        .splitView(availablePositions: [.top, .bottom, .center, .leading, .trailing],
                                   proposalPosition: $dropProposal,
                                   margin: 15,
                                   onDrop: handleDropProposal)
                default:
                    codeEditorView(fileItem, for: selectedItem)
                        .splitView(availablePositions: [.top, .bottom, .center, .leading, .trailing],
                                   proposalPosition: $dropProposal,
                                   margin: 15,
                                   onDrop: handleDropProposal)
                }
            } else {
                EmptyEditorView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    @ViewBuilder
    private func codeEditorView(
        _ codeFile: CodeFileDocument,
        for item: FileSystemClient.FileItem
    ) -> some View {
        CodeEditorViewWrapper(codeFile: codeFile, fileExtension: item.url.pathExtension)
            .safeAreaInset(edge: .top, spacing: 0) {
                VStack(spacing: 0) {
                    BreadcrumbsView(file: item, tappedOpenFile: workspace.openTab(item:))
                    Divider()
                }
            }
    }

    @ViewBuilder
    private func imageFileView(
        _ otherFile: CodeFileDocument,
        for item: FileSystemClient.FileItem
    ) -> some View {
        GeometryReader { proxy in
            if let url = otherFile.previewItemURL,
               let image = NSImage(contentsOf: url),
               otherFile.typeOfFile == .image {

                let imageView = OtherFileView(otherFile)

                if image.size.width > proxy.size.width || image.size.height > proxy.size.height {
                    imageView
                } else {
                    imageView
                        .frame(width: image.size.width, height: image.size.height)
                        .position(x: proxy.frame(in: .local).midX, y: proxy.frame(in: .local).midY)
                }
            } else {
                OtherFileView(otherFile)
            }
        }
        .safeAreaInset(edge: .top, spacing: 0) {
            VStack(spacing: 0) {
                BreadcrumbsView(file: item, tappedOpenFile: workspace.openTab(item:))
                Divider()
            }
        }
    }

    private func handleDropProposal(position: SplitViewProposalDropPosition,
                                    dropInfo: DropInfo) {
        switch position {
        case .top:
            Log.info("Dropped at the top")
        case .bottom:
            Log.info("Dropped at the bottom")
        case .leading:
            Log.info("Dropped at the start")
        case .trailing:
            Log.info("Dropped at the end")
        case .center:
            Log.info("Dropped at the center")
        }
    }

    var body: some View {
        codeView
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
