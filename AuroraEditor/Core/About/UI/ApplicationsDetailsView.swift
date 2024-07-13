//
//  ApplicationsDetailsView.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2023/01/21.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

/// The view that displays the details of the application
struct ApplicationsDetailsView: View {

    @Binding
    /// The state of the detail view
    var aboutDetailState: AboutDetailState

    @State
    /// Is the user hovering on the commit hash
    private var hoveringOnCommitHash = false

    /// The app version
    private var appVersion: String {
        Bundle.versionString ?? "about.no.version".localize()
    }

    /// The app build
    private var appBuild: String {
        Bundle.buildString ?? "about.no.build".localize()
    }

    /// The commit hash
    private var commitHash: String {
        Bundle.commitHash ?? "about.no.hash".localize()
    }

    /// The short commit hash
    private var shortCommitHash: String {
        if commitHash.count > 7 {
            return String(commitHash[...commitHash.index(commitHash.startIndex, offsetBy: 7)])
        }
        return commitHash
    }

    /// The view body
    var body: some View {
        VStack {
            VStack {
                Image(nsImage: NSApp.applicationIconImage)
                    .resizable()
                    .frame(width: 75, height: 75)
                    .accessibilityLabel(Text("Aurora Editor Logo"))

                Text("Aurora Editor")
                    .font(.system(size: 24, weight: .regular))

                Text(
                    "about.version".localized(appVersion, appBuild)
                )
                    .textSelection(.enabled)
                    .foregroundColor(.secondary)
                    .font(.system(size: 12, weight: .light))
                    .padding(.top, -10)
                    .padding(.bottom, 5)

                HStack(spacing: 2.0) {
                    Text("")
                    Text(self.hoveringOnCommitHash ?
                         commitHash : shortCommitHash)
                    .textSelection(.enabled)
                    .onHover { hovering in
                        self.hoveringOnCommitHash = hovering
                    }
                    .animation(.easeInOut, value: self.hoveringOnCommitHash)
                }
                .foregroundColor(.secondary)
                .font(.system(size: 10, weight: .light))
            }
            .frame(height: 210)

            Spacer()

            VStack(spacing: 10) {
                Text("about.license")
                    .onTapGesture {
                        aboutDetailState = .license
                    }
                    .accessibilityAddTraits(.isButton)
                    .foregroundColor(aboutDetailState == .license ? .white : .secondary)
                    .padding(.vertical, 5)
                    .padding(.horizontal)
                    .background(aboutDetailState == .license ? Color(nsColor: NSColor(.accentColor)) : .clear)
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: 20
                        )
                    )

                Text("about.contributors")
                    .onTapGesture {
                        aboutDetailState = .contributers
                    }
                    .accessibilityAddTraits(.isButton)
                    .foregroundColor(aboutDetailState == .contributers ? .white : .secondary)
                    .padding(.vertical, 5)
                    .padding(.horizontal)
                    .background(aboutDetailState == .contributers ? Color(nsColor: NSColor(.accentColor)) : .clear)
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: 20
                        )
                    )

                Text("about.credits")
                    .onTapGesture {
                        aboutDetailState = .credits
                    }
                    .accessibilityAddTraits(.isButton)
                    .foregroundColor(aboutDetailState == .credits ? .white : .secondary)
                    .padding(.vertical, 5)
                    .padding(.horizontal)
                    .background(aboutDetailState == .credits ? Color(nsColor: NSColor(.accentColor)) : .clear)
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: 20
                        )
                    )
            }

            Spacer()
        }
        .frame(height: 370)
    }
}

struct ApplicationsDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        ApplicationsDetailsView(aboutDetailState: .constant(.license))
    }
}
