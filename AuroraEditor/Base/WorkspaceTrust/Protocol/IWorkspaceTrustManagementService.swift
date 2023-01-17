//
//  IWorkspaceTrustManagementService.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/12/20.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import Foundation

protocol IWorkspaceTrustManagementService {
    var serviceBrand: Any? { get }

    func onDidChangeTrust() -> Bool
    func onDidChangeTrustedFolders() async throws

    func workspaceResolved() async throws
    func workspaceTrustInitialized() async throws
    func acceptsOutOfWorkspaceFiles() -> Bool

    func isWorkspaceTrusted() -> Bool
    func isWorkspaceTrustForced() -> Bool

    func canSetParentFolderTrust() -> Bool
    func setParentFolderTrust(trusted: Bool)

    func canSetWorkspaceTrust() -> Bool
    func setWorkspaceTrust(trusted: Bool)

    func getUriTrustInfo(url: URL) async throws -> IWorkspaceTrustUriInfo
    func setURLTrust(url: [URL], trusted: Bool)

    func getTrustedUris() -> [URL]
    func setTrustedUris(urls: [URL]) async throws
}

func workspaceTrustToString(trusted: Bool) -> String {
    if trusted {
        return "Trusted"
    } else {
        return "Restricted Mode"
    }
}
