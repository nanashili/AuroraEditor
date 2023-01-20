//
//  WorkspaceTrustActiveView.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2023/01/02.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

struct WorkspaceTrustActiveView: View {

    @State
    private var prefs: AppPreferencesModel = .shared

    var body: some View {
        Form {
            Section {
                VStack(alignment: .leading) {
                    HStack {
                        Text("Show Trust Notifications")
                            .font(.subheadline)
                        Spacer()
                        Picker("Trust Notifications",
                               selection: $prefs.preferences.privacySecurity.trustNotification) {
                            ForEach(TrustNotifications.allCases, id: \.self) {
                                Text($0.rawValue)
                                    .font(.subheadline)
                                    .tag($0)
                            }
                        }
                        .font(.subheadline)
                        .labelsHidden()
                        .frame(width: 160)
                    }

                    Divider()

                    HStack {
                        Text("Untrusted File Action")
                            .font(.subheadline)
                        Spacer()
                        Picker("Trust Untrusted Files",
                               selection: $prefs.preferences.privacySecurity.untrustedFileAction) {
                            ForEach(UntrustedFileAction.allCases, id: \.self) {
                                Text($0.rawValue)
                                    .font(.subheadline)
                                    .tag($0)
                            }
                        }
                        .font(.subheadline)
                        .labelsHidden()
                        .frame(width: 160)
                    }

                    Divider()

                    HStack {
                        Text("Trust Window on Startup Action")
                            .font(.subheadline)
                        Spacer()
                        Picker("Trust Startup Prompt",
                               selection: $prefs.preferences.privacySecurity.startupAction) {
                            ForEach(StartupAction.allCases, id: \.self) {
                                Text($0.rawValue)
                                    .font(.subheadline)
                                    .tag($0)
                            }
                        }
                        .font(.subheadline)
                        .labelsHidden()
                        .frame(width: 160)
                    }

                    Divider()

                    HStack {
                        Text("Trust Empty Windows")
                            .font(.subheadline)
                        Spacer()
                        Toggle("", isOn: $prefs.preferences.privacySecurity.trustEmptyWorkspace)
                            .toggleStyle(.switch)
                            .labelsHidden()
                    }
                }
            }
        }
    }
}

struct WorkspaceTrustActiveView_Previews: PreviewProvider {
    static var previews: some View {
        WorkspaceTrustActiveView()
    }
}
