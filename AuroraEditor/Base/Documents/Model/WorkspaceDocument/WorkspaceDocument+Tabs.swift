//
//  WorkspaceDocument+Tabs.swift
//  Aurora Editor
//
//  Created by TAY KAI QUAN on 8/8/22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation
import Version_Control
import SwiftUI

extension WorkspaceDocument {

    // MARK: - Tab Actions:

    /// Pins a tab and moves it to the front of the opened tabs.
    ///
    /// This function checks if the specified tab item is not already pinned. If it is not pinned,
    /// it inserts the item into the `pinnedTabs` collection. It then moves the pinned tab to the
    /// front of the `openedTabs` array to ensure that pinned tabs are always displayed first.
    ///
    /// - Parameter item: The identifier of the tab to pin.
    func pinTab(item: TabBarItemID) {
        if !selectionState.pinnedTabs.contains(item) {
            selectionState.pinnedTabs.insert(item)

            // Move the pinned tab to the front of openedTabs
            if let index = selectionState.openedTabs.firstIndex(of: item) {
                selectionState.openedTabs.remove(at: index)
                selectionState.openedTabs.insert(item, at: 0)
            }
        }
    }

    /// Unpins a tab and moves it to the back of the opened tabs.
    ///
    /// This function checks if the specified tab item is currently pinned. If it is pinned,
    /// it removes the item from the `pinnedTabs` collection. It then moves the unpinned tab
    /// to the back of the `openedTabs` array to ensure that unpinned tabs are displayed after
    /// all pinned tabs.
    ///
    /// - Parameter item: The identifier of the tab to unpin.
    func unpinTab(item: TabBarItemID) {
        if selectionState.pinnedTabs.contains(item) {
            selectionState.pinnedTabs.remove(item)

            // Move the unpinned tab to the back of openedTabs
            if let index = selectionState.openedTabs.firstIndex(of: item) {
                let unpinnedTab = selectionState.openedTabs.remove(at: index)
                selectionState.openedTabs.append(unpinnedTab)
            }
        }
    }

    /// Checks if a tab is pinned.
    ///
    /// This function checks if the specified tab item is in the `pinnedTabs` collection,
    /// indicating that it is currently pinned.
    ///
    /// - Parameter item: The identifier of the tab to check.
    /// - Returns: A Boolean value indicating whether the tab is pinned (`true`) or not (`false`).
    func isTabPinned(_ item: TabBarItemID) -> Bool {
        return selectionState.pinnedTabs.contains(item)
    }

    // MARK: Open Tabs

    /// Opens new tab
    /// - Parameter item: any item which can be represented as a tab
    func openTab(item: TabBarItemRepresentable) {
        guard !selectionState.openedTabs.contains(item.tabID) else { return }

        switch item.tabID {
        case .codeEditor:
            guard let file = item as? FileSystemClient.FileItem else { return }
            openFile(item: file)
        case .extensionInstallation:
            guard let plugin = item as? Plugin else { return }
            openExtension(item: plugin)
        case .webTab:
            guard let webTab = item as? WebTab else { return }
            openWebTab(item: webTab)
        case .projectHistory:
            guard let projectCommitHistoryTab = item as? ProjectCommitHistory else { return }
            openProjectCommitHistory(item: projectCommitHistoryTab)
        case .branchHistory:
            guard let branchCommitHistoryTab = item as? BranchCommitHistory else { return }
            openBranchCommitHistory(item: branchCommitHistoryTab)
        case .actionsWorkflow:
            guard let actionsWorkflowTab = item as? Workflow else { return }
            openActionsWorkflow(item: actionsWorkflowTab)
        case .extensionCustomView:
            guard let extensionCustomViewTab = item as? ExtensionCustomViewModel else { return }
            openExtensionCustomView(item: extensionCustomViewTab)
        }

        updateNewlyOpenedTabs(item: item)
        selectionState.selectedId = item.tabID
    }

    /// Updates the opened tabs and temporary tab.
    /// - Parameter item: The item to use to update the tab state.
    private func updateNewlyOpenedTabs(item: TabBarItemRepresentable) {
        if let temporaryTab = selectionState.temporaryTab,
           let index = selectionState.openedTabs.firstIndex(of: temporaryTab) {
            closeTemporaryTab()
            selectionState.openedTabs[index] = item.tabID
        } else {
            selectionState.openedTabs.append(item.tabID)
        }

        selectionState.previousTemporaryTab = selectionState.temporaryTab
        selectionState.temporaryTab = item.tabID
    }

    private func openFile(item: FileSystemClient.FileItem) {
        guard !selectionState.openFileItems.contains(item) else { return }

        selectionState.openFileItems.append(item)

        DispatchQueue.global(qos: .userInitiated).async {
            let pathExtension = item.url.pathExtension
            do {
                let codeFile = try CodeFileDocument(
                    for: item.url,
                    withContentsOf: item.url,
                    ofType: pathExtension
                )
                DispatchQueue.main.async {
                    self.selectionState.openedCodeFiles[item] = codeFile
                }

                let fileData = try? Data(contentsOf: item.url)
                ExtensionsManager.shared.sendEvent(
                    event: "didOpen",
                    parameters: [
                        "workspace": self.fileURL?.relativeString ?? "Unknown",
                        "file": item.url.relativeString,
                        "contents": String(data: fileData ?? Data(), encoding: .utf8) ?? ""
                    ]
                )
            } catch {
                Log.fault("\(error)")
            }
        }
    }

    private func openExtension(item: Plugin) {
        if !selectionState.openedExtensions.contains(item) {
            selectionState.openedExtensions.append(item)
        }
    }

    private func openWebTab(item: WebTab) {
        // its not possible to have the same web tab opened multiple times, so no need to check
        selectionState.openedWebTabs.append(item)
    }

    private func openProjectCommitHistory(item: ProjectCommitHistory) {
        selectionState.openedProjectCommitHistory.append(item)
    }

    private func openBranchCommitHistory(item: BranchCommitHistory) {
        selectionState.openedBranchCommitHistory.append(item)
    }

    private func openActionsWorkflow(item: Workflow) {
        selectionState.openedActionsWorkflow.append(item)
    }

    private func openExtensionCustomView(item: ExtensionCustomViewModel) {
        selectionState.openedCustomExtensionViews.append(item)
    }

    // MARK: Close Tabs

    /// Closes single tab
    /// - Parameter id: tab bar item's identifier to be closed
    func closeTab(item id: TabBarItemID) {
        if id == selectionState.temporaryTab {
            selectionState.previousTemporaryTab = selectionState.temporaryTab
            selectionState.temporaryTab = nil
        }

        guard let idx = selectionState.openedTabs.firstIndex(of: id) else { return }
        selectionState.openedTabs.remove(at: idx)

        switch id {
        case .codeEditor:
            guard let item = selectionState.getItemByTab(id: id) as? FileSystemClient.FileItem else { return }
            closeFileTab(item: item)
            ExtensionsManager.shared.sendEvent(
                event: "didClose",
                parameters: ["file": item.url.relativeString]
            )
        case .extensionInstallation:
            guard let item = selectionState.getItemByTab(id: id) as? Plugin else { return }
            closeExtensionTab(item: item)
        case .webTab:
            guard let item = selectionState.getItemByTab(id: id) as? WebTab else { return }
            closeWebTab(item: item)
        case .projectHistory:
            guard let item = selectionState.getItemByTab(id: id) as? ProjectCommitHistory else { return }
            closeProjectCommitHistoryTab(item: item)
        case .branchHistory:
            guard let item = selectionState.getItemByTab(id: id) as? BranchCommitHistory else { return }
            closeBranchCommitHistoryTab(item: item)
        case .actionsWorkflow:
            guard let item = selectionState.getItemByTab(id: id) as? Workflow else { return }
            closeActionsWorkflowTab(item: item)
        case .extensionCustomView:
            guard let item = selectionState.getItemByTab(id: id) as? ExtensionCustomViewModel else { return }
            closeExtensionCustomView(item: item)
            ExtensionsManager.shared.sendEvent(event: "didCloseExtensionView", parameters: ["view": item])
        }

        if selectionState.openedTabs.isEmpty {
            selectionState.selectedId = nil
        } else if selectionState.selectedId == id {
            selectionState.selectedId = idx == 0 ? selectionState.openedTabs.first : selectionState.openedTabs[idx - 1]
        }

        unpinTab(item: id)
    }

    /// Closes collection of tab bar items
    /// - Parameter items: items to be closed
    func closeTabs<Items>(items: Items) where Items: Collection, Items.Element == TabBarItemID {
        items.forEach { closeTab(item: $0) }
    }

    /// Closes tabs according to predicator
    /// - Parameter predicate: predicator which returns whether tab should be closed based on its identifier
    func closeTab(where predicate: (TabBarItemID) -> Bool) {
        let itemsToClose = selectionState.openedTabs.filter(predicate)
        closeTabs(items: itemsToClose)
    }

    /// Closes tabs after specified identifier
    /// - Parameter id: identifier after which tabs will be closed
    func closeTabs(after id: TabBarItemID) {
        guard let startIdx = selectionState.openFileItems.firstIndex(where: { $0.tabID == id }) else {
            assertionFailure("Expected file item to be present in openFileItems")
            return
        }

        let range = selectionState.openedTabs[(startIdx + 1)...]
        closeTabs(items: range)
    }

    func closeAllExceptHoveredTab(hoveredTabID: TabBarItemID) {
        let tabsToClose = selectionState.openedTabs.filter { $0 != hoveredTabID }
        closeTabs(items: tabsToClose)

        if selectionState.selectedId != hoveredTabID {
            selectionState.selectedId = hoveredTabID
        }
    }

    /// Closes an open temporary tab, does not save the temporary tab's file.
    /// Removes the tab item from `openedCodeFiles`, `openedExtensions`, and `openFileItems`.
    private func closeTemporaryTab() {
        guard let id = selectionState.temporaryTab else { return }

        switch id {
        case .codeEditor:
            if let item = selectionState.getItemByTab(id: id) as? FileSystemClient.FileItem {
                selectionState.openedCodeFiles.removeValue(forKey: item)
                if let idx = selectionState.openFileItems.firstIndex(of: item) {
                    Log.info("Removing temp tab")
                    selectionState.openFileItems.remove(at: idx)
                }
            }
        case .extensionInstallation:
            if let item = selectionState.getItemByTab(id: id) as? Plugin {
                closeExtensionTab(item: item)
            }
        case .webTab:
            if let item = selectionState.getItemByTab(id: id) as? WebTab {
                closeWebTab(item: item)
            }
        case .projectHistory:
            if let item = selectionState.getItemByTab(id: id) as? ProjectCommitHistory {
                closeProjectCommitHistoryTab(item: item)
            }
        case .branchHistory:
            if let item = selectionState.getItemByTab(id: id) as? BranchCommitHistory {
                closeBranchCommitHistoryTab(item: item)
            }
        case .actionsWorkflow:
            if let item = selectionState.getItemByTab(id: id) as? Workflow {
                closeActionsWorkflowTab(item: item)
            }
        case .extensionCustomView:
            if let item = selectionState.getItemByTab(id: id) as? ExtensionCustomViewModel {
                closeExtensionCustomView(item: item)
            }
        }

        if let openFileItemIdx = selectionState.openFileItems.firstIndex(where: { $0.tabID == id }) {
            selectionState.openFileItems.remove(at: openFileItemIdx)
        }
    }

    /// Closes an open tab, save text files only.
    /// Removes the tab item from `openedCodeFiles`, `openedExtensions`, and `openFileItems`.
    private func closeFileTab(item: FileSystemClient.FileItem) {
        if let file = selectionState.openedCodeFiles.removeValue(forKey: item), file.typeOfFile != .image {
            file.saveFileDocument()
        }

        if let idx = selectionState.openFileItems.firstIndex(of: item) {
            selectionState.openFileItems.remove(at: idx)
        }
    }

    private func closeExtensionTab(item: Plugin) {
        if let idx = selectionState.openedExtensions.firstIndex(of: item) {
            selectionState.openedExtensions.remove(at: idx)
        }
    }

    private func closeWebTab(item: WebTab) {
        if let idx = selectionState.openedWebTabs.firstIndex(of: item) {
            selectionState.openedWebTabs.remove(at: idx)
        }
    }

    private func closeProjectCommitHistoryTab(item: ProjectCommitHistory) {
        if let idx = selectionState.openedProjectCommitHistory.firstIndex(of: item) {
            selectionState.openedProjectCommitHistory.remove(at: idx)
        }
    }

    private func closeBranchCommitHistoryTab(item: BranchCommitHistory) {
        if let idx = selectionState.openedBranchCommitHistory.firstIndex(of: item) {
            selectionState.openedBranchCommitHistory.remove(at: idx)
        }
    }

    private func closeActionsWorkflowTab(item: Workflow) {
        if let idx = selectionState.openedActionsWorkflow.firstIndex(of: item) {
            selectionState.openedActionsWorkflow.remove(at: idx)
        }
    }

    private func closeExtensionCustomView(item: ExtensionCustomViewModel) {
        if let idx = selectionState.openedCustomExtensionViews.firstIndex(of: item) {
            selectionState.openedCustomExtensionViews.remove(at: idx)
        }
    }

    /// Makes the temporary tab permanent when a file save or edit happens.
    @objc func convertTemporaryTab() {
        if selectionState.selectedId == selectionState.temporaryTab && selectionState.temporaryTab != nil {
            selectionState.previousTemporaryTab = selectionState.temporaryTab
            selectionState.temporaryTab = nil
        }
    }
}
