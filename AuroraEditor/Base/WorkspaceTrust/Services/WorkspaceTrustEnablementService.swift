//
//  WorkspaceTrustEnablementService.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/12/20.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import Foundation

/// This class handles the checking of workspace trust, if the user has workspace trust enabled in the preferences
struct WorkspaceTrustEnablementService: IWorkspaceTrustEnablementService {

    private let preferences: AppPreferencesModel = .shared

    /// If the workspace trust has been disabled by the user in the preference settings
    /// we return the function as false making all workspaces trust disabled.
    public func isWorkspaceTrustEnabled() -> Bool {
        if preferences.preferences.editor.disableWorkspaceTrust {
            return false
        }

        return true
    }
}
