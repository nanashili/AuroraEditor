//
//  IWorkspaceTrustEnablementService.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/12/20.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import Foundation

protocol IWorkspaceTrustEnablementService {
    /// A function that checks if the workspace trust is enabled
    /// - Returns: returns the value of the workspace trust in preferences
    func isWorkspaceTrustEnabled() -> Bool
}
