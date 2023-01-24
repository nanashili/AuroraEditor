//
//  IWorkspaceTrustRequestService.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/12/20.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import Foundation

protocol IWorkspaceTrustRequestService {
    func completeOpenFilesTrustRequest(result: WorkspaceTrustUriResponse,
                                       saveResponse: Bool?)
    func requestOpenFilesTrust(openFiles: [URL]) -> WorkspaceTrustUriResponse
    func completeWorkspaceTrustRequest(trusted: Bool?)
    func requestWorkspaceTrust(options: WorkspaceTrustUriResponse?) -> Bool
}

enum WorkspaceTrustUriResponse: Int {
    case open = 1
    case openInNewWindow = 2
    case cancel = 3
}
