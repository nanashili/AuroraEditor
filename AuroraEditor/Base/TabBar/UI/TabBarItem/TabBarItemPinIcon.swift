//
//  TabBarItemPinIcon.swift.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2024/05/30.
//  Copyright © 2024 Aurora Company. All rights reserved.
//

import SwiftUI

struct TabBarItemPinIcon: View {
    @EnvironmentObject
    var workspace: WorkspaceDocument

    var prefs: AppPreferencesModel
    var item: TabBarItemRepresentable

    var body: some View {
        if workspace.isTabPinned(item.tabID) {
            Image(systemName: "pin.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(.gray)
                .frame(width: 10, height: 10)
                .rotationEffect(.degrees(35))
                .padding(.trailing, prefs.preferences.general.tabBarStyle == .xcode ? 7.5 : 9)
        }
    }
}
