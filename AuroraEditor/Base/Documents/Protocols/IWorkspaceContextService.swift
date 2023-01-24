//
//  IWorkspaceContextService.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2023/01/24.
//  Copyright © 2023 Aurora Company. All rights reserved.
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
