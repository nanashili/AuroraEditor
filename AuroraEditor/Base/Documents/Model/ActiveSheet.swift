//
//  ActiveSheet.swift
//  Aurora Editor
//
//  Created by Tihan-Nico Paxton on 2024/05/29.
//  Copyright © 2024 Aurora Company. All rights reserved.
//

import Foundation

enum ActiveSheet: Identifiable {
    case fileCreation
    case stashChanges
    case renameBranch
    case addRemote
    case branchCreation
    case tagCreation
    case custom

    var id: Int {
        switch self {
        case .fileCreation: return 0
        case .stashChanges: return 1
        case .renameBranch: return 2
        case .addRemote: return 3
        case .branchCreation: return 4
        case .tagCreation: return 5
        case .custom: return 6
        }
    }
}
