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
    private var trustNotificationState: TrustNotification = .untilDismissed

    @State
    private var trustEmptyWindow: Bool = false

    @State
    private var trustUntrustedFiles: TrustUntrustedFiles = .open

    @State
    private var trustStartupPrompt: TrustStartupPrompt = .once

    var body: some View {
        Form {
            Section {
                VStack(alignment: .leading) {
                    HStack {
                        Text("Trust Notifications")
                            .font(.subheadline)
                        Spacer()
                        Picker("Trust Notifications",
                               selection: $trustNotificationState) {
                            ForEach(TrustNotification.allCases, id: \.self) {
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
                        Text("Trust Empty Window")
                            .font(.subheadline)
                        Spacer()
                        Toggle("", isOn: $trustEmptyWindow)
                            .toggleStyle(.switch)
                            .labelsHidden()
                    }

                    Divider()

                    HStack {
                        Text("Trust Untrusted Files")
                            .font(.subheadline)
                        Spacer()
                        Picker("Trust Untrusted Files",
                               selection: $trustUntrustedFiles) {
                            ForEach(TrustUntrustedFiles.allCases, id: \.self) {
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
                        Text("Trust Startup Prompt")
                            .font(.subheadline)
                        Spacer()
                        Picker("Trust Startup Prompt",
                               selection: $trustStartupPrompt) {
                            ForEach(TrustStartupPrompt.allCases, id: \.self) {
                                Text($0.rawValue)
                                    .font(.subheadline)
                                    .tag($0)
                            }
                        }
                        .font(.subheadline)
                        .labelsHidden()
                        .frame(width: 160)
                    }
                }
            }
        }
    }

    private enum TrustNotification: String, CaseIterable {
        case always = "Always"
        case untilDismissed = "Until Dismissed"
        case never = "Never"
    }

    private enum TrustUntrustedFiles: String, CaseIterable {
        case promt = "Prompt"
        case open = "Open"
        case openNewWindow = "Open New Window"
    }

    private enum TrustStartupPrompt: String, CaseIterable {
        case always = "Always"
        case once = "Once"
        case never = "Never"
    }
}

struct WorkspaceTrustActiveView_Previews: PreviewProvider {
    static var previews: some View {
        WorkspaceTrustActiveView()
    }
}
