//
//  TabBarItemIcon.swift
//  Aurora Editor
//
//  Created by TAY KAI QUAN on 10/9/22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

extension TabBarItem {
    @ViewBuilder
    var iconTextView: some View {
        HStack(alignment: .center, spacing: 5) {
            item.icon
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(
                    prefs.preferences.general.fileIconStyle == .color && activeState != .inactive
                    ? item.iconColor
                    : .secondary
                )
                .frame(width: 12, height: 12)
            Text(item.title)
                .font(
                    isTemporary
                    ? .system(size: 11.0).italic()
                    : .system(size: 11.0)
                )
                .lineLimit(1)
        }
        .frame(
            maxWidth: prefs.preferences.general.tabBarStyle == .native ? .infinity : nil,
            maxHeight: .infinity
        )
        .padding(.horizontal, prefs.preferences.general.tabBarStyle == .native ? 28 : 23)
        .overlay {
            ZStack {
                if isActive {
                    Button(
                        action: closeAction,
                        label: { EmptyView() }
                    )
                    .frame(width: 0, height: 0)
                    .padding(0)
                    .opacity(0)
                    .keyboardShortcut("w", modifiers: [.command, .option])
                }
                Button(
                    action: switchAction,
                    label: { EmptyView() }
                )
                .frame(width: 0, height: 0)
                .padding(0)
                .opacity(0)
                .keyboardShortcut(
                    workspace.getTabKeyEquivalent(item: item),
                    modifiers: [.command]
                )
                .background(.blue)
                TabBarItemCloseButton(
                    closeAction: closeAction,
                    isActive: isActive,
                    colorScheme: colorScheme,
                    prefs: prefs,
                    isHovering: isHovering
                )
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .overlay {
            ZStack {
                TabBarItemPinIcon(prefs: prefs, item: item)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }
}

fileprivate extension WorkspaceDocument {
    func getTabKeyEquivalent(item: TabBarItemRepresentable) -> KeyEquivalent {
        for counter in 0..<9 where self.selectionState.openFileItems.count > counter &&
        self.selectionState.openFileItems[counter].tabID == item.tabID {
            return KeyEquivalent(Character("\(counter + 1)")
            )
        }
        return "0"
    }
}
