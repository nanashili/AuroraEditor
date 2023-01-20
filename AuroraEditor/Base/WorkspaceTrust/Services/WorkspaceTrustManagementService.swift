//
//  WorkspaceTrustManagementService.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/12/20.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import Foundation

struct WorkspaceTrustManagementService: IWorkspaceTrustManagementService {
    var serviceBrand: Any?

    private var canonicalUrisResolved: Bool = false
    private var workspace: WorkspaceDocument = WorkspaceDocument()
    private var isTrusted: Bool = false
    private var trustStateInfo: IWorkspaceTrustInfo = IWorkspaceTrustInfo(uriTrustInfo: [])

    // MARK: - Private

    // The canonical path is really just an absolute path but for the
    // sake of keeping a more clear and consistent naming convention
    // we create the below function that returns the absolute url.
    private func getCanonicalUrl() -> URL {
        return self.currentWorkspaceUrl().absoluteURL
    }

    private func saveTrustInfo() async {}

    private func getWorkspaceUrls() -> [URL] {
        []
    }

    private func calculateWorkspaceTrust() -> Bool {
        if !WorkspaceTrustEnablementService().isWorkspaceTrustEnabled() {
            return true
        }

        return false
    }

    private func updateWorkspaceTrust(trusted: Bool?) async {}

    private func currentWorkspaceUrl() -> URL {
        return workspace.fileSystemClient?.folderURL ?? URL(string: "")!
    }

    private func getUrlsTrust(urls: [URL]) -> Bool {
        var state = true
        for url in urls {
            let trusted = false

            if !trusted {
                state = trusted
                return state
            }
        }

        return state
    }

    private func doGetUrlTrustInfo(url: URL) -> IWorkspaceTrustUriInfo {
        if WorkspaceTrustEnablementService().isWorkspaceTrustEnabled() {
            return IWorkspaceTrustUriInfo(uri: url,
                                          trusted: true)
        }

        var resultState = false
        var maxLength = -1

        var resultURL = url

        for trustInfo in trustStateInfo.uriTrustInfo {
            // swiftlint:disable:next for_where
            if url == trustInfo.uri {
                let path = trustInfo.uri.absoluteString
                if path.count > maxLength {
                    maxLength = path.count
                    resultState = trustInfo.trusted
                    resultURL = trustInfo.uri
                }

            }
        }

        return IWorkspaceTrustUriInfo(uri: resultURL,
                                      trusted: resultState)
    }

    private func doSetUrlsTrust(urls: [URL], trusted: Bool) async {
        var changed = false

        for url in urls {
            // swiftlint:disable:next for_where
            if trusted {
                var foundItem = trustStateInfo.uriTrustInfo.contains { trustInfo in
                    trustInfo.uri == url
                }

                if !foundItem {
                    trustStateInfo.uriTrustInfo.append(IWorkspaceTrustUriInfo(uri: url,
                                                                              trusted: true))
                    changed = true
                } else {
                    let previousLength = trustStateInfo.uriTrustInfo.count

                    trustStateInfo.uriTrustInfo = trustStateInfo.uriTrustInfo.filter { trustInfo in
                        trustInfo.uri != url
                    }

                    if previousLength != trustStateInfo.uriTrustInfo.count {
                        changed = true
                    }
                }
            }
        }

        if changed {
            await saveTrustInfo()
        }
    }

    private func isEmptyWorkspace() -> Bool {
        if workspace.getWorkbenchState() == .empty {
            return true
        }

        return false
    }

    private func isTrusted(value: Bool) {
        if !value {

        }
    }

    // MARK: - Public
    func onDidChangeTrust() -> Bool {
        false
    }

    func onDidChangeTrustedFolders() async throws {}

    func workspaceResolved() async throws {}

    func workspaceTrustInitialized() async throws {}

    func acceptsOutOfWorkspaceFiles() -> Bool {
        false
    }

    /// We check if the current workspace that the user has open is trusted
    func isWorkspaceTrusted() -> Bool {
        return isTrusted
    }

    public func isWorkspaceTrustForced() -> Bool {
        false
    }

    func canSetParentFolderTrust() -> Bool {
        let workspaceIdentifier = workspace.workspaceURL()
        let parentFolder = workspace.workspaceURL()

        if parentFolder == workspaceIdentifier {
            return false
        }

        return false
    }

    func setParentFolderTrust(trusted: Bool) {
        if canSetParentFolderTrust() {
            let workspaceUri = workspace.workspaceURL()
            let parentFolder = workspaceUri

            setURLTrust(url: [parentFolder],
                        trusted: trusted)
        }
    }

    func canSetWorkspaceTrust() -> Bool {

        // Untrusted workspace
        if !isWorkspaceTrusted() {
            return true
        }

        // If the current folder isn't trusted directly, return false
        let trustInfo = doGetUrlTrustInfo(url: workspace.workspaceURL())
        if !trustInfo.trusted || trustInfo.uri == workspace.workspaceURL() {
            return false
        }

        // Check if the parent is also trusted
        if canSetParentFolderTrust() {
            let parentFolder = workspace.workspaceURL()
            let parentPathTrustInfo = doGetUrlTrustInfo(url: parentFolder)
            if parentPathTrustInfo.trusted {
                return false
            }
        }

        return false
    }

    public func setWorkspaceTrust(trusted: Bool) {
        let workspaceFolders = getWorkspaceUrls()
        setURLTrust(url: workspaceFolders,
                    trusted: true)
    }

    func getUriTrustInfo(url: URL) -> IWorkspaceTrustUriInfo {
        // Return trusted when workspace trust is disabled
        if !WorkspaceTrustEnablementService().isWorkspaceTrustEnabled() {
            return IWorkspaceTrustUriInfo(uri: url,
                                          trusted: true)
        }

        return doGetUrlTrustInfo(url: url)
    }

    func setURLTrust(url: [URL], trusted: Bool) {}

    func getTrustedUris() -> [URL] {
        return trustStateInfo.uriTrustInfo.map { info in
            info.uri
        }
    }

    func setTrustedUris(urls: [URL]) async throws {
        trustStateInfo.uriTrustInfo = []

        for url in urls {
            var added = false

            for addedURL in trustStateInfo.uriTrustInfo {
                // swiftlint:disable:next for_where
                if addedURL.uri == url {
                    added = true
                }
            }

            if added {
                continue
            }

            trustStateInfo.uriTrustInfo.append(IWorkspaceTrustUriInfo(uri: url,
                                                                      trusted: true))
        }

        // When the url has been trusted we save it to preferences
        await saveTrustInfo()
    }
}
