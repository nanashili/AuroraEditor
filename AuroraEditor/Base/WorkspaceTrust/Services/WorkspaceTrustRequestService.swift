//
//  WorkspaceTrustRequestService.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2023/01/17.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

class WorkspaceTrustRequestService: IWorkspaceTrustRequestService {

    private var workspace: WorkspaceDocument = WorkspaceDocument()

    func completeOpenFilesTrustRequest(result: WorkspaceTrustUriResponse, saveResponse: Bool?) {
        // Set acceptsOutOfWorkspaceFiles
        if result == WorkspaceTrustUriResponse.open {
            WorkspaceTrustManagementService().acceptsOutOfWorkspaceFiles()
        }

        // TODO: Save response, still need to create preference setting for this
        if saveResponse ?? false {
            if result == WorkspaceTrustUriResponse.open {

            }
        }
    }

    func requestOpenFilesTrust(openFiles: [URL]) -> WorkspaceTrustUriResponse {
        if WorkspaceTrustManagementService().isWorkspaceTrusted() {
            return WorkspaceTrustUriResponse.open
        }

        var openFileURLS = openFiles.map { url in
            WorkspaceTrustManagementService().getUriTrustInfo(url: url)
        }

        for info in openFileURLS {
            // swiftlint:disable:next for_where
            if info.trusted {
                return WorkspaceTrustUriResponse.open
            }
        }

        // If we already asked the user, don't need to ask again
        if WorkspaceTrustManagementService().acceptsOutOfWorkspaceFiles() {
            return WorkspaceTrustUriResponse.open
        }

        return WorkspaceTrustUriResponse.cancel
    }

    func completeWorkspaceTrustRequest(trusted: Bool?) {
        WorkspaceTrustManagementService().setWorkspaceTrust(trusted: trusted ?? false)
    }

    func requestWorkspaceTrust(options: WorkspaceTrustUriResponse?) -> Bool {
        // Trusted workspace
        if WorkspaceTrustManagementService().isWorkspaceTrusted() {
            return WorkspaceTrustManagementService().isWorkspaceTrusted()
        }

        // This will show the sheet that will handle the approval of the workspace.
        workspace.data.showWorkspaceTrustDialog.toggle()

        return true
    }
}
