//
//  IEditorSetupService.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2023/01/09.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

protocol IEditorSetupService {
    func isFirstTimeUse() -> Bool
    func updateEditorUsage(value: Bool)
    func openSetupWindow()
}
