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

struct WorkspaceView: View {
    let tabBarHeight = 28.0
    private var path: String = ""

    @StateObject
    private var prefs: AppPreferencesModel = .shared

    @State
    private var activeSheet: ActiveSheet?

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

    var body: some View {
        ZStack {
            if workspace.fileSystemClient != nil, let model = workspace.statusBarModel {
                ZStack {
                    if let tabID = workspace.selectionState.selectedId {
                        TabViews(workspace: workspace)
                            .tabContentForID(tabID: tabID)
                    } else {
                        EmptyEditorView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background {
                    if prefs.preferences.general.tabBarStyle == .xcode {
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
                handleBroadcast(broadcast)
            }.store(in: &cancelables)
        }
        .onDisappear {
            if enterFullscreenObserver != nil {
                NotificationCenter.default.removeObserver(enterFullscreenObserver!)
            }
            if leaveFullscreenObserver != nil {
                NotificationCenter.default.removeObserver(leaveFullscreenObserver!)
            }
        }
        .environment(\.isFullscreen, self.isFullscreen)
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
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .fileCreation:
                FileCreationSelectionView(workspace: workspace)
            case .stashChanges:
                StashChangesSheet(workspaceURL: workspace.workspaceURL())
            case .renameBranch:
                RenameBranchView(workspace: workspace,
                                 currentBranchName: workspace.data.currentlySelectedBranch,
                                 newBranchName: workspace.data.currentlySelectedBranch)
            case .addRemote:
                AddRemoteView(workspace: workspace)
            case .branchCreation:
                CreateNewBranchView(workspace: workspace,
                                    revision: workspace.data.branchRevision,
                                    revisionDesciption: workspace.data.branchRevisionDescription)
            case .tagCreation:
                CreateNewTagView(workspace: workspace,
                                 commitHash: workspace.data.commitHash)
            case .custom:
                VStack {
                    HStack {
                        Text(extensionDynamic.title)
                        Spacer()
                        Button("Dismiss") {
                            activeSheet = nil
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

    private func presentSheet(_ sheet: ActiveSheet) {
        activeSheet = sheet
    }

    private func handleBroadcast(_ broadcast: AuroraCommandBroadcaster.Broadcast) {
        Log.info("\(broadcast.command)")
        extensionDynamic.name = broadcast.sender
        extensionDynamic.title = (broadcast.parameters["title"] as? String) ?? extensionDynamic.name

        switch broadcast.command {
        case "NOOP":
            break
        case "openSettings":
            workspace.windowController?.openSettings()
        case "showNotification":
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
        case "showWarning":
            notificationService.warn(
                title: extensionDynamic.title,
                message: (broadcast.parameters["message"] as? String) ?? ""
            )
        case "showError":
            notificationService.error(
                title: extensionDynamic.title,
                message: (broadcast.parameters["message"] as? String) ?? ""
            )
        case "openSheet":
            if let view = broadcast.parameters["view"] {
                extensionDynamic.view = AnyView(
                    ExtensionOrWebView(view: view, sender: broadcast.sender)
                )
                sheetIsOpened = true
            }
        case "openTab":
            workspace.openTab(
                item: ExtensionCustomViewModel(
                    name: extensionDynamic.title,
                    view: broadcast.parameters["view"],
                    sender: broadcast.sender
                )
            )
        default:
            Log.info("\(broadcast.command)")
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
