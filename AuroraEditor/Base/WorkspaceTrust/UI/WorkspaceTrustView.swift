//
//  WorkspaceTrustView.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/12/18.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import SwiftUI

struct WorkspaceTrustView: View {

    @State
    var workspace: WorkspaceDocument

    private var workspaceTrustEnabled: Bool = WorkspaceTrustEnablementService().isWorkspaceTrustEnabled()

    init(workspace: WorkspaceDocument) {
        self.workspace = workspace
    }

    var body: some View {
        VStack {
            HStack {
                Image(systemName: "lock.trianglebadge.exclamationmark")
                    .symbolRenderingMode(.multicolor)
                    .font(.title)

                Text(workspaceTrustEnabled ? getHeaderTitleText(trusted: true) : "Workspace Trust Disabled")
                    .font(.title)
                    .fontWeight(.bold)
            }
            .padding(.top, 40)

            // swiftlint:disable:next line_length
            Text("Workspace Trust provides an extra layer of security when working with \nunfamiliar code, by preventing automatic code execution of any code in your \nworkspace if the workspace is open in Restricted Mode.")
                .multilineTextAlignment(.center)
                .font(.system(size: 12))
                .padding(.top, 5)

            HStack(alignment: .top, spacing: 10) {
                WorkspaceTrustedFolderView()
                WorkspaceRestrictedFolderView()
            }
            .padding(.vertical)
            .border(.separator)
            .padding(.top, 40)

            HStack {
                VStack(alignment: .leading) {
                    Text("Trusted Folders and Workspaces")
                        .font(.title3)
                        .fontWeight(.medium)
                    Text("You trust the following folders, subfolders and workspaces below:")

                    List {
                        WorkspaceTrustListItemView(folderPath: "Users/tihan-nico/Downloads")
                        WorkspaceTrustListItemView(folderPath: "Users/tihan-nico/Documents")
                        WorkspaceTrustListItemView(folderPath: "/Users/tihan-nico/findercomm")
                    }
                    .frame(height: 120)

                    Button {
                    } label: {
                        Text("Add Folder")
                            .padding()
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding(.top)

                Spacer()
            }
            .padding(.horizontal, -5)

            Spacer()
        }
        .frame(width: 790)
    }

    func getHeaderTitleText(trusted: Bool) -> String {
        if trusted {
            switch workspace.getWorkbenchState() {
            case .empty:
                return "You trust this window"
            case .folder:
                return "You trust this folder"
            case .workspace:
                return "You trust this workspace"
            }
        }

        return "You are in Restricted Mode"
    }
}

struct WorkspaceTrustView_Previews: PreviewProvider {
    static var previews: some View {
        WorkspaceTrustView(workspace: .init())
            .frame(width: 790, height: 900)
    }
}
