//
//  WorkspaceTrustEnableView.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2023/01/02.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

struct WorkspaceTrustEnableView: View {

    @State
    private var preferences: AppPreferencesModel = .shared

    @State
    private var workspaceTrustDisabled: Bool = false

    init() {
        self.workspaceTrustDisabled = preferences.preferences.editor.disableWorkspaceTrust
    }

    var body: some View {
        VStack {
            HStack(alignment: .top) {
                Image(systemName: "lock.shield")
                    .imageScale(.medium)
                    .scaledToFit()
                    .foregroundColor(.white)
                    .frame(width: 30, height: 30)
                    .background(
                        RoundedRectangle(
                            cornerRadius: 5)
                        .foregroundColor(.blue)
                        .opacity(0.8)
                    )

                VStack(alignment: .leading) {
                    Text("Workspace Trust")
                        .font(.system(size: 13, weight: .medium))

                    // swiftlint:disable:next line_length
                    Text("Workspace Trust provides an extra layer of security when working with \nunfamiliar code, by preventing automatic code execution of any code in your \nworkspace if the workspace is open in Restricted Mode. [Learn more...](https://auroraeditor.com/faq/workspace-trust)")
                        .foregroundColor(.secondary)
                        .padding(.top, -5)
                        .font(.subheadline)
                }

                Spacer()

                Button {
                    if workspaceTrustDisabled {
                        preferences.preferences.editor.disableWorkspaceTrust = false
                        info(workspaceTrustDisabled)
                    } else {
                        preferences.preferences.editor.disableWorkspaceTrust = true
                        info(workspaceTrustDisabled)
                    }
                } label: {
                    if workspaceTrustDisabled {
                        Text("Turn On...")
                    } else {
                        Text("Turn Off...")
                    }
                }
            }
        }
    }
}

struct WorkspaceTrustEnableView_Previews: PreviewProvider {
    static var previews: some View {
        WorkspaceTrustEnableView()
    }
}
