//
//  TabViews.swift
//  Aurora Editor
//
//  Created by Tihan-Nico Paxton on 2024/05/29.
//  Copyright © 2024 Aurora Company. All rights reserved.
//

import SwiftUI
import Version_Control

struct TabViews {
    @EnvironmentObject
    private var workspace: WorkspaceDocument

    private let extensionView = ExtensionViewStorage.shared

    @ViewBuilder
    func tabContentForID(tabID: TabBarItemID) -> some View {
        switch tabID {
        case .codeEditor:
            WorkspaceCodeFileView()
        case .extensionInstallation:
            extensionInstallationView()
        case .webTab:
            webTabView()
        case .projectHistory:
            projectHistoryView()
        case .branchHistory:
            branchHistoryView()
        case .actionsWorkflow:
            actionsWorkflowView()
        case .extensionCustomView:
            extensionCustomView()
        }
    }

    @ViewBuilder
    private func extensionInstallationView() -> some View {
        if let plugin = workspace.selectionState.selected as? Plugin {
            ExtensionView(extensionData: plugin)
        } else {
            EmptyView()
        }
    }

    @ViewBuilder
    private func webTabView() -> some View {
        if let webTab = workspace.selectionState.selected as? WebTab {
            WebTabView(webTab: webTab)
        } else {
            EmptyView()
        }
    }

    @ViewBuilder
    private func projectHistoryView() -> some View {
        if let projectHistoryTab = workspace.selectionState.selected as? ProjectCommitHistory {
            ProjectCommitHistoryView(projectHistoryModel: projectHistoryTab)
        } else {
            EmptyView()
        }
    }

    @ViewBuilder
    private func branchHistoryView() -> some View {
        if let branchHistoryTab = workspace.selectionState.selected as? BranchCommitHistory {
            BranchCommitHistoryView(branchCommitModel: branchHistoryTab)
        } else {
            EmptyView()
        }
    }

    @ViewBuilder
    private func actionsWorkflowView() -> some View {
        if let actionsWorkflowTab = workspace.selectionState.selected as? Workflow {
            WorkflowRunsView(workspace: workspace, workflowId: String(actionsWorkflowTab.id))
        } else {
            EmptyView()
        }
    }

    @ViewBuilder
    private func extensionCustomView() -> some View {
        if let customTab = workspace.selectionState.selected as? ExtensionCustomViewModel,
           let view = extensionView.storage.first(where: { $0.key == customTab.id })?.value {
            ExtensionOrWebView(view: view, sender: customTab.sender)
        } else {
            EmptyView()
        }
    }
}
