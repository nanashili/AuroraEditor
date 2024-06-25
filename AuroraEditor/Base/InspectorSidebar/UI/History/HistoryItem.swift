//
//  HistoryItem.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/03/24.
//  Copyright © 2023 Aurora Company. All rights reserved.
//
import SwiftUI
import Version_Control

// The source control history cell view
struct HistoryItem: View {

    /// The commit history
    var commit: CommitHistory

    /// The selected commit history
    @Binding
    var selection: CommitHistory?

    /// Show an popup?
    private var showPopup: Binding<Bool> {
        Binding<Bool> {
            selection == commit
        } set: { newValue in
            if newValue {
                selection = commit
            } else {
                selection = nil
            }
        }
    }

    /// Open URL environment
    @Environment(\.openURL)
    private var openCommit

    /// Initialize with a commit history and a selection
    /// 
    /// - Parameter commit: the commit history
    /// - Parameter selection: the selection
    /// 
    /// - Returns: a new HistoryItem instance
    init(commit: CommitHistory, selection: Binding<CommitHistory?>) {
        self.commit = commit
        self._selection = selection
    }

    /// The view body
    var body: some View {
        VStack(alignment: .trailing) {
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    Text(commit.author)
                        .fontWeight(.bold)
                        .font(.system(size: 11))
                    Text(commit.message)
                        .font(.system(size: 11))
                        .lineLimit(2)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 5) {
                    Text(commit.hash)
                        .font(.system(size: 10))
                        .background(
                            RoundedRectangle(cornerRadius: 3)
                                .padding(.trailing, -5)
                                .padding(.leading, -5)
                                .foregroundColor(Color(nsColor: .quaternaryLabelColor))
                        )
                        .padding(.trailing, 5)
                    Text(commit.date.relativeStringToNow())
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
                .padding(.top, 1)
            }
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 10)
        .contentShape(Rectangle())
        .popover(isPresented: showPopup, arrowEdge: .leading) {
            PopoverView(commit: commit)
        }
        .contextMenu {
            Group {
                Button("Copy Commit Message") {
                    let pasteboard = NSPasteboard.general
                    pasteboard.clearContents()
                    pasteboard.setString(commit.message, forType: .string)
                }
                Button("Copy Identifier") {}
                    .disabled(true) // TODO: Implementation Needed
                Button("Email \(commit.author)...") {
                    let service = NSSharingService(named: NSSharingService.Name.composeEmail)
                    service?.recipients = [commit.authorEmail]
                    service?.perform(withItems: [])
                }
                Divider()
            }
            Group {
                Button("Tag \(commit.hash)...") {}
                    .disabled(true) // TODO: Implementation Needed
                Button("New Branch from \(commit.hash)...") {}
                    .disabled(true) // TODO: Implementation Needed
                Button("Cherry-Pick \(commit.hash)...") {}
                    .disabled(true) // TODO: Implementation Needed
            }
            Group {
                Divider()
                if let commitRemoteURL = commit.commitBaseURL?.absoluteString {
                    Button("View on \(commit.remoteString)...") {
                        let commitURL = "\(commitRemoteURL)/\(commit.commitHash)"
                        openCommit(URL(string: commitURL)!)
                    }
                    Divider()
                }
                Button("Check Out \(commit.hash)...") {}
                    .disabled(true) // TODO: Implementation Needed
                Divider()
                Button("History Editor Help") {}
                    .disabled(true) // TODO: Implementation Needed
            }
        }
    }
}
