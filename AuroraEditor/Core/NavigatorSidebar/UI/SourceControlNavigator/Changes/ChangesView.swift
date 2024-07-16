//
//  ChangesView.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/05/20.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

/// A view for changes.
struct ChangesView: View {

    /// The workspace.
    @EnvironmentObject
    var workspace: WorkspaceDocument

    /// Application preferences model
    @ObservedObject
    private var prefs: AppPreferencesModel = .shared

    /// The changes model.
    @ObservedObject
    var versionControl: VersionControlModel = .shared

    /// The view body.
    var body: some View {
        VStack(alignment: .center) {
            if prefs.sourceControlActive() {
                if versionControl.workspaceIsRepository {
                    switch workspace.fileSystemClient?.model?.state {
                    case .success:
                        if let changed = workspace.fileSystemClient?.model?.changed,
                           changed.isEmpty {
                            Text("No Changes")
                                .font(.system(size: 16))
                                .foregroundColor(.secondary)
                        } else {
                            SourceControlView()
                            CommitChangesView(workspace: workspace)
                        }
                    case .loading:
                        VStack {
                            Text("Loading Changes")
                                .font(.system(size: 16))
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    case .error:
                        VStack {
                            Text("Failed To Find Changes")
                                .font(.system(size: 16))
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    case .none:
                        VStack {
                            Text("Failed To Find Changes")
                                .font(.system(size: 16))
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                } else {
                    Text("This project does not seem to be a Git repository.")
                        .padding(.horizontal)
                        .multilineTextAlignment(.center)
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                }
            } else {
                VStack {
                    Text("Source Control Disabled")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)

                    Text("Enable Source Control in settings")
                        .font(.system(size: 10))
                }
            }
        }
        .frame(maxHeight: .infinity)
    }
}
