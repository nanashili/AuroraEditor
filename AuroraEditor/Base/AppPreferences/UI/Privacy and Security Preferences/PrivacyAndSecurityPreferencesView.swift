//
//  PrivacyAndSecurityPreferencesView.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2023/01/02.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

struct PrivacyAndSecurityPreferencesView: View {

    @State
    private var preferences: AppPreferencesModel = .shared

    @State
    private var workspaceTrustDisabled: Bool = false

    init() {
        self.workspaceTrustDisabled = preferences.preferences.editor.disableWorkspaceTrust
    }

    var body: some View {
        Form {
            Text("Security")
                .fontWeight(.bold)
                .padding(.horizontal)
                .padding(.top, 5)

            Group {
                GroupBox {
                    WorkspaceTrustEnableView()
                        .padding(5)
                }
                if !workspaceTrustDisabled {
                    withAnimation {
                        GroupBox {
                            WorkspaceTrustActiveView()
                                .padding(5)
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

struct PrivacyAndSecurityPreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        PrivacyAndSecurityPreferencesView()
    }
}
