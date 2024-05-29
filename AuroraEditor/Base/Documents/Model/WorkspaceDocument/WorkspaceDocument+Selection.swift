//
//  WorkspaceDocument+Selection.swift
//  Aurora Editor
//
//  Created by Pavel Kasila on 30.04.22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation
import Version_Control

struct WorkspaceSelectionState: Codable {
    var selectedId: TabBarItemID?
    var pinnedTabs: Set<TabBarItemID> = []
    var openedTabs: [TabBarItemID] = [] {
        didSet {
            // Move pinned tabs to the front
            openedTabs = openedTabs.sorted { tab1, tab2 in
                if pinnedTabs.contains(tab1) && !pinnedTabs.contains(tab2) {
                    return true
                } else if !pinnedTabs.contains(tab1) && pinnedTabs.contains(tab2) {
                    return false
                } else {
                    // Use a safe comparison to avoid force unwrapping
                    if let index1 = openedTabs.firstIndex(of: tab1),
                       let index2 = openedTabs.firstIndex(of: tab2) {
                        return index1 < index2
                    } else {
                        return false
                    }
                }
            }
        }
    }
    var savedTabs: [TabBarItemStorage] = []
    var flattenedSavedTabs: [TabBarItemStorage] {
        var flat = [TabBarItemStorage]()
        for tab in savedTabs {
            flat.append(tab)
            flat.append(contentsOf: tab.flattenedChildren)
        }
        return flat
    }
    var temporaryTab: TabBarItemID?
    var previousTemporaryTab: TabBarItemID?

    var workspace: WorkspaceDocument?

    var selected: TabBarItemRepresentable? {
        guard let selectedId = selectedId else { return nil }
        return getItemByTab(id: selectedId)
    }

    var openFileItems: [FileSystemClient.FileItem] = []
    var openedCodeFiles: [FileSystemClient.FileItem: CodeFileDocument] = [:]

    var openedExtensions: [Plugin] = []

    var openedWebTabs: [WebTab] = []

    var openedProjectCommitHistory: [ProjectCommitHistory] = []

    var openedBranchCommitHistory: [BranchCommitHistory] = []

    var openedActionsWorkflow: [Workflow] = []

    var openedCustomExtensionViews: [ExtensionCustomViewModel] = []

    enum CodingKeys: String, CodingKey {
        case selectedId,
             openedTabs,
             temporaryTab,
             openedExtensions,
             openedWebTabs,
             projectCommitHistory,
             branchCommitHistory,
             openedExtensionViews
    }

    init() {
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        selectedId = try container.decode(TabBarItemID?.self, forKey: .selectedId)
        openedTabs = try container.decode([TabBarItemID].self, forKey: .openedTabs)
        temporaryTab = try container.decode(TabBarItemID?.self, forKey: .temporaryTab)
        openedExtensions = try container.decode([Plugin].self, forKey: .openedExtensions)
        openedWebTabs = try container.decode([WebTab].self, forKey: .openedWebTabs)
        openedCustomExtensionViews = try container.decode(
            [ExtensionCustomViewModel].self,
            forKey: .openedExtensionViews
        )
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(selectedId, forKey: .selectedId)
        try container.encode(openedTabs, forKey: .openedTabs)
        try container.encode(temporaryTab, forKey: .temporaryTab)
        try container.encode(openedExtensions, forKey: .openedExtensions)
        try container.encode(openedWebTabs, forKey: .openedWebTabs)
        try container.encode(openedCustomExtensionViews, forKey: .openedExtensionViews)
    }

    /// Returns TabBarItemRepresentable by its identifier
    /// - Parameter id: tab bar item's identifier
    /// - Returns: item with passed identifier
    func getItemByTab(id: TabBarItemID) -> TabBarItemRepresentable? {
        switch id {
        case .codeEditor:
            let path = id.id.replacingOccurrences(of: "codeEditor_", with: "")
            // get it from the open file items, else fallback to the whole index
            if let fileItem = self.openFileItems.first(where: { $0.tabID == id }) {
                return fileItem
            }
            return try? workspace?.fileSystemClient?.getFileItem(path)
        case .extensionInstallation:
            return self.openedExtensions.first { item in
                item.tabID == id
            }
        case .webTab:
            return self.openedWebTabs.first { item in
                item.tabID == id
            }
        case .projectHistory:
            return self.openedProjectCommitHistory.first { item in
                item.tabID == id
            }
        case .branchHistory:
            return self.openedBranchCommitHistory.first { item in
                item.tabID == id
            }
        case .actionsWorkflow:
            return self.openedActionsWorkflow.first { item in
                item.tabID == id
            }
        case .extensionCustomView:
            return self.openedCustomExtensionViews.first { item in
                item.tabID == id
            }
        }
    }
}
