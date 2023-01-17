//
//  IWorkspaceContextService.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/12/20.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import Foundation

protocol IWorkspaceContextService {
    func getWorkbenchState() -> WorkbenchState
}

enum WorkbenchState: Int {
    case empty = 1
    case folder = 2
    case workspace = 3
}
