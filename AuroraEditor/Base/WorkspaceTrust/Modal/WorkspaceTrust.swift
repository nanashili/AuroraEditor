//
//  WorkspaceTrust.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/12/18.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import SwiftUI

class WorkspaceTrust: Equatable, TabBarItemRepresentable, Codable {

    static func == (lhs: WorkspaceTrust, rhs: WorkspaceTrust) -> Bool {
        guard lhs.tabID == rhs.tabID else { return false }
        guard lhs.title == rhs.title else { return false }
        return true
    }

    var tabID: TabBarItemID {
        .workspaceTrust("workspace_trust")
    }

    var title: String {
        return "Workspace Trust"
    }

    var icon: Image {
        Image(systemName: "lock.shield.fill")
    }

    var iconColor: Color {
        return .secondary
    }
}
