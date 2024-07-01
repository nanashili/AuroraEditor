//
//  AccountItemView.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/08/19.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

/// The account item view
struct AccountItemView: View {
    /// The open URL environment
    @Environment(\.openURL)
    var openGithubProfile

    /// The account
    @Binding
    var account: AccountPreferences

    /// The delete callback
    var onDeleteCallback: (String) -> Void

    /// The view body
    var body: some View {
        GroupBox {
            VStack(alignment: .leading) {
                HStack {
                    AsyncImage(url: URL(string: account.accountImage)) { phase in
                        if let image = phase.image {
                            image
                                .resizable()
                                .clipShape(Circle())
                                .frame(width: 42, height: 42)
                        } else if phase.error != nil {
                            defaultAvatar
                        } else {
                            defaultAvatar
                        }
                    }

                    Text(account.accountName)
                        .foregroundColor(.primary)

                    Spacer()

                    Button {
                        openGithubProfile(URL(string: "\(account.providerLink)/\(account.accountUsername)")!)
                    } label: {
                        Text("settings.account.show.profile")
                            .foregroundColor(.primary)
                    }
                }
                .padding(.top, 5)
                .padding(.horizontal, 10)

                Divider()

                HStack {
                    Text("settings.account.username")

                    Spacer()

                    Text(account.accountUsername)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)

                Divider()

                HStack {
                    Text("settings.account.username.description \(account.provider)")
                        .foregroundColor(.secondary)
                        .font(.system(size: 11))
                        .padding(6)
                        .padding(.horizontal, 5)
                    Spacer()
                    Button("global.delete") {
                        onDeleteCallback(account.id)
                    }
                }
            }
        }
    }

    private var defaultAvatar: some View {
        Image(systemName: "person.crop.circle.fill")
            .symbolRenderingMode(.hierarchical)
            .resizable()
            .foregroundColor(.gray)
            .frame(width: 42, height: 42)
            .accessibilityLabel(Text("Account Avatar"))
    }
}
