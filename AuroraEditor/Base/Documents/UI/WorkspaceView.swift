//
//  WorkspaceView.swift
//  Aurora Editor
//
//  Created by Austin Condiff on 3/10/22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI
import AppKit
import Version_Control
import Combine

class ExtensionDynamicData: ObservableObject {
    @Published
    public var name: String

    @Published
    public var title: String = ""

    @Published
    public var view: AnyView = AnyView(EmptyView())

    init() {
        self.name = ""
        self.title = ""
        self.view = AnyView(EmptyView())
    }
}

struct WorkspaceView: View {
    let tabBarHeight = 28.0
    private var path: String = ""

    @StateObject
    private var prefs: AppPreferencesModel = .shared

    @EnvironmentObject
    private var workspace: WorkspaceDocument

    private let notificationService: NotificationService = .init()

    @State
    var cancelables: Set<AnyCancellable> = .init()

    @State
    private var showingAlert = false

    @State
    private var alertTitle = ""

    @State
    private var alertMsg = ""

    @State
    var showInspector = true

    /// The fullscreen state of the NSWindow.
    /// This will be passed into all child views as an environment variable.
    @State
    var isFullscreen = false

    @State
    private var enterFullscreenObserver: Any?

    @State
    private var leaveFullscreenObserver: Any?

    @State
    private var sheetIsOpened = false

    @ObservedObject
    private var extensionDynamic = ExtensionDynamicData()

    private let extensionsManagerShared = ExtensionsManager.shared
    private let extensionView = ExtensionViewStorage.shared

    @ViewBuilder
    func tabContentForID(tabID: TabBarItemID) -> some View {
        switch tabID {
        case .codeEditor:
            WorkspaceCodeFileView()
        case .extensionInstallation:
            if let plugin = workspace.selectionState.selected as? Plugin {
                ExtensionView(extensionData: plugin)
            }
        case .webTab:
            if let webTab = workspace.selectionState.selected as? WebTab {
                WebTabView(webTab: webTab)
            }
        case .projectHistory:
            if let projectHistoryTab = workspace.selectionState.selected as? ProjectCommitHistory {
                ProjectCommitHistoryView(projectHistoryModel: projectHistoryTab)
            }
        case .branchHistory:
            if let branchHistoryTab = workspace.selectionState.selected as? BranchCommitHistory {
                BranchCommitHistoryView(branchCommitModel: branchHistoryTab)
            }
        case .actionsWorkflow:
            if let actionsWorkflowTab = workspace.selectionState.selected as? Workflow {
                WorkflowRunsView(workspace: workspace,
                                 workflowId: String(actionsWorkflowTab.id))
            }
        case .extensionCustomView:
            if let customTab = workspace.selectionState.selected as? ExtensionCustomViewModel {
                ExtensionOrWebView(view: extensionView.storage.first(where: {
                    $0.key == customTab.id
                })?.value, sender: customTab.sender)
            }
        }
    }

    var body: some View {
        ZStack {
            if workspace.fileSystemClient != nil, let model = workspace.statusBarModel {
                ZStack {
                    if let tabID = workspace.selectionState.selectedId {
                        tabContentForID(tabID: tabID)
                    } else {
                        EmptyEditorView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background {
                    if prefs.preferences.general.tabBarStyle == .xcode {
                        // Use the same background material as xcode tab bar style.
                        // Only when the tab bar style is set to `xcode`.
                        TabBarXcodeBackground()
                    }
                }
                .safeAreaInset(edge: .top, spacing: 0) {
                    VStack(spacing: 0) {
                        TabBar(sourceControlModel: workspace.fileSystemClient?.model ??
                            .init(workspaceURL: workspace.fileURL!))
                        Divider().foregroundColor(.secondary)
                    }
                }
                .safeAreaInset(edge: .bottom) {
                    StatusBarView(model: model)
                }
            } else {
                EmptyView()
            }
        }
        .alert(alertTitle, isPresented: $showingAlert, actions: {
            Button(
                action: { showingAlert = false },
                label: { Text("OK") }
            )
        }, message: { Text(alertMsg) })
        .onChange(of: workspace.selectionState.selectedId) { newValue in
            if newValue == nil {
                workspace.windowController?.window?.subtitle = ""
            }
        }
        .onAppear {
            extensionsManagerShared.set(workspace: workspace)
            // There may be other methods to monitor the full-screen state.
            // But I cannot find a better one for now because I need to pass this into the SwiftUI.
            // And it should always be updated.
            enterFullscreenObserver = NotificationCenter.default.addObserver(
                forName: NSWindow.didEnterFullScreenNotification,
                object: nil,
                queue: .current,
                using: { _ in self.isFullscreen = true }
            )
            leaveFullscreenObserver = NotificationCenter.default.addObserver(
                forName: NSWindow.willExitFullScreenNotification,
                object: nil,
                queue: .current,
                using: { _ in self.isFullscreen = false }
            )

            workspace.broadcaster.broadcaster.sink { broadcast in
                Log.info("\(broadcast.command)")
                extensionDynamic.name = broadcast.sender
                extensionDynamic.title = (broadcast.parameters["title"] as? String) ?? extensionDynamic.name

                if broadcast.command == "NOOP" {
                    // Got a noop command, we can ignore this.
                } else if broadcast.command == "openSettings" {
                    workspace.windowController?.openSettings()
                } else if broadcast.command == "showNotification" {
                    notificationService.notify(
                        notification: INotification(
                            id: UUID().uuidString,
                            severity: .info,
                            title: extensionDynamic.title,
                            message: (broadcast.parameters["message"] as? String) ?? "",
                            notificationType: .extensionSystem,
                            silent: false
                        )
                    )
                } else if broadcast.command == "showWarning" {
                    notificationService.warn(
                        title: extensionDynamic.title,
                        message: (broadcast.parameters["message"] as? String) ?? ""
                    )
                } else if broadcast.command == "showError" {
                    notificationService.error(
                        title: extensionDynamic.title,
                        message: (broadcast.parameters["message"] as? String) ?? ""
                    )
                } else if broadcast.command == "openSheet",
                    let view = broadcast.parameters["view"] {
                    extensionDynamic.view = AnyView(
                        ExtensionOrWebView(view: view, sender: broadcast.sender)
                    )
                    sheetIsOpened = true
                } else if broadcast.command == "openTab" {
                    Log.info("openTab")
                    workspace.openTab(
                        item: ExtensionCustomViewModel(
                            name: extensionDynamic.title,
                            view: broadcast.parameters["view"],
                            sender: broadcast.sender
                        )
                    )
                } else if broadcast.command == "openWindow",
                   let view = broadcast.parameters["view"] {
                    let window = NSWindow()
                    window.styleMask = NSWindow.StyleMask(rawValue: 0xf)
                    window.contentViewController = NSHostingController(
                        rootView: ExtensionOrWebView(view: view, sender: broadcast.sender).padding(5)
                    )
                    window.setFrame(
                        NSRect(x: 700, y: 200, width: 500, height: 500),
                        display: false
                    )
                    let windowController = NSWindowController()
                    windowController.contentViewController = window.contentViewController
                    windowController.window = window
                    windowController.window?.title = extensionDynamic.title
                    windowController.showWindow(self)
                } else {
                    Log.info("Unknown broadcast command \(broadcast.command)")
                }
            }.store(in: &cancelables)
        }
        .onDisappear {
            // Unregister the observer when the view is going to disappear.
            if enterFullscreenObserver != nil {
                NotificationCenter.default.removeObserver(enterFullscreenObserver!)
            }
            if leaveFullscreenObserver != nil {
                NotificationCenter.default.removeObserver(leaveFullscreenObserver!)
            }
        }
        // Send the environment to all subviews.
        .environment(\.isFullscreen, self.isFullscreen)
        // When tab bar style is changed, update NSWindow configuration as follows.
        .onChange(of: prefs.preferences.general.tabBarStyle) { newStyle in
            DispatchQueue.main.async {
                if newStyle == .native {
                    workspace.windowController?.window?.titlebarAppearsTransparent = true
                    workspace.windowController?.window?.titlebarSeparatorStyle = .none
                } else {
                    workspace.windowController?.window?.titlebarAppearsTransparent = false
                    workspace.windowController?.window?.titlebarSeparatorStyle = .automatic
                }
            }
        }
        .sheet(isPresented: $workspace.newFileModel.showFileCreationSheet) {
            FileCreationSelectionView(workspace: workspace)
        }
        .sheet(isPresented: $workspace.data.showStashChangesSheet) {
            StashChangesSheet(workspaceURL: workspace.workspaceURL())
        }
        .sheet(isPresented: $workspace.data.showRenameBranchSheet) {
            RenameBranchView(workspace: workspace,
                             currentBranchName: workspace.data.currentlySelectedBranch,
                             newBranchName: workspace.data.currentlySelectedBranch)
        }
        .sheet(isPresented: $workspace.data.showAddRemoteView) {
            AddRemoteView(workspace: workspace)
        }
        .sheet(isPresented: $workspace.data.showBranchCreationSheet) {
            CreateNewBranchView(workspace: workspace,
                                revision: workspace.data.branchRevision,
                                revisionDesciption: workspace.data.branchRevisionDescription)
        }
        .sheet(isPresented: $workspace.data.showTagCreationSheet) {
            CreateNewTagView(workspace: workspace,
                             commitHash: workspace.data.commitHash)

        }
        .sheet(isPresented: $sheetIsOpened) {
            VStack {
                HStack {
                    Text(extensionDynamic.title)
                    Spacer()
                    Button("Dismiss") {
                        sheetIsOpened.toggle()
                    }
                }.padding([.leading, .top, .trailing], 5)
                Divider()
                extensionDynamic.view
                    .padding(.bottom, 5)
            }
            .frame(minWidth: 250, minHeight: 150)
        }
    }
}

struct WorkspaceView_Previews: PreviewProvider {
    static var previews: some View {
        WorkspaceView()
    }
}

private struct WorkspaceFullscreenStateEnvironmentKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

extension EnvironmentValues {
    var isFullscreen: Bool {
        get { self[WorkspaceFullscreenStateEnvironmentKey.self] }
        set { self[WorkspaceFullscreenStateEnvironmentKey.self] = newValue }
    }
}
