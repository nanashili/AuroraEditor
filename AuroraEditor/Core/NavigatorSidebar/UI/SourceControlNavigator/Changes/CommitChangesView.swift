//
//  CommitChangesView.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/08/11.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI
import OSLog
import Version_Control

/// A view for committing changes.
struct CommitChangesView: View {

    /// The git client.
    private var gitClient: GitClient?

    /// The summary text.
    @State
    private var summaryText: String = ""

    /// The description text.
    @State
    private var descriptionText: String = ""

    /// The workspace.
    @State
    var workspace: WorkspaceDocument

    @ObservedObject
    private var versionControl: VersionControlModel = .shared

    /// Whether to stage all changes.
    @State
    private var stageAll: Bool = false

    @State
    private var addCoAuthors: Bool = false

    @State
    private var addedCoAuthors: String = ""

    @State
    private var showSuggestions: Bool = false
    @State
    private var suggestions: [IAPIMentionableUser] = []
    @State
    private var filteredSuggestions: [IAPIMentionableUser] = []

    @State
    private var height: CGFloat = 95
    @State
    private var isExpanded: Bool = false

    /// The view body.
    /// 
    /// - Parameter workspace: The workspace.
    init(workspace: WorkspaceDocument) {
        self.workspace = workspace
        self.gitClient = workspace.fileSystemClient?.model?.gitClient
    }

    /// The view body.
    var body: some View {
        VStack(alignment: .leading) {
            summaryView
                .animation(.smooth(), value: height)

            VStack(alignment: .leading, spacing: 10) {
                descriptionTextField
                coAuthorToggle

                if addCoAuthors {
                    CoAuthorSection(
                        addedCoAuthors: $addedCoAuthors,
                        suggestions: $suggestions,
                        showSuggestions: $showSuggestions,
                        filteredSuggestions: $filteredSuggestions,
                        versionControl: versionControl
                    )
                    .onDisappear {
                        addedCoAuthors = ""
                    }
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .frame(
                height: height,
                alignment: .topLeading
            )
            .padding(10)
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color.secondary, lineWidth: 0.5)
            )
            .animation(.smooth(), value: height)

            Button(action: commit) {
                Spacer()
                Text("Commit to **\(versionControl.currentWorkspaceBranch)**")
                    .foregroundColor(.white)
                    .font(.system(size: 11))
                    .padding(.vertical, 5)
                Spacer()
            }
            .buttonStyle(.borderedProminent)
            .frame(width: .infinity)
            .disabled(summaryText.isEmpty)
        }
        .padding(10)
        .onChange(of: showSuggestions) { _ in updateHeight() }
        .onChange(of: addCoAuthors) { _ in updateHeight() }
        .animation(.easeInOut, value: isExpanded)
        .onAppear {
            suggestions = versionControl.githubRepositoryMentionables
        }
    }

    private func updateHeight() {
        if showSuggestions {
            height = addCoAuthors ? 235 : 95
        } else {
            height = addCoAuthors ? 125 : 95
        }
    }

    private var summaryView: some View {
        VStack {
            Divider()
                .padding(.leading, 5)
                .padding(.horizontal, -15)
                .padding(.bottom, 5)

            HStack(alignment: .center) {
                Avatar().gitAvatar(
                    imageSize: 30,
                    authorEmail: versionControl.workspaceEmail
                )
                .help("The workspace is configured with the following Git account: \(versionControl.workspaceEmail)")

                HStack(spacing: 0) {
                    TextField(text: $summaryText) {
                        Text(checkIfChangeIsOne() ? getFirstFileSummary() : "Summary (Required)")
                            .font(.system(size: 11, weight: .medium))
                    }
                    .font(.system(size: 11, weight: .medium))
                    .padding(.vertical, 6)
                    .padding(.leading, 10)
                    .padding(.trailing, 10)
                    .textFieldStyle(.plain)

                    if summaryText.count > 50 {
                        Image(systemName: "info.circle")
                            .padding(.trailing, 10)
                            .help("Ideal commit summaries are concise (under 50 chars) and descriptive")
                            .accessibilityLabel("Character count warning")
                            .accessibilityHint("Tap for information about ideal commit summary length")
                            .accessibilityAddTraits(.isButton)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.secondary, lineWidth: 0.5)
                )
                .disabled(getFirstFileSummary() == "Unable to commit")
            }
        }
    }

    private var descriptionTextField: some View {
        ZStack(alignment: .topLeading) {
            if descriptionText.isEmpty {
                Text("Description")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)
                    .padding(.top, 1)
                    .padding(.leading, 4)
                    .transition(.opacity)
            }
            TextEditor(text: $descriptionText)
                .font(.system(size: 11, weight: .medium))
                .frame(height: 70)
                .scrollContentBackground(.hidden)
                .background(Color.clear)
        }
        .frame(height: 70, alignment: .topLeading)
        .animation(.easeInOut, value: descriptionText.isEmpty)
    }

    private var coAuthorToggle: some View {
        Button {
            self.addCoAuthors.toggle()
        } label: {
            Label(
                addCoAuthors ? "Remove Co-Authors" : "Add Co-Authors",
                systemImage: "person.badge.plus"
            )
            .font(.system(size: 11))
            .foregroundColor(.secondary)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(.isButton)
    }

    /// Gets the first file summary.
    /// 
    /// Based on the Git Change type of the file we create a summary string
    /// that matches that of the Git Change type
    ///
    /// - Returns: The summary string.
    private func getFirstFileSummary() -> String {
        let fileName = workspace.fileSystemClient?.model?.changed[0].fileName
        switch workspace.fileSystemClient?.model?.changed[0].gitStatus {
        case .modified:
            return "Update \(fileName ?? "Unknown File")"
        case .added:
            return "Created \(fileName ?? "Unknown File")"
        case .copied:
            return "Copied \(fileName ?? "Unknown File")"
        case .deleted:
            return "Deleted \(fileName ?? "Unknown File")"
        case .fileTypeChange:
            return "Changed file type \(fileName ?? "Unknown File")"
        case .renamed:
            return "Renamed \(fileName ?? "Unknown File")"
        case .unknown:
            return "Summary (Required)"
        case .updatedUnmerged:
            return "Unmerged file \(fileName ?? "Unknown File")"
        case .ignored:
            return "Ignore file \(fileName ?? "Unknown File")"
        case .unchanged:
            return "Unchanged"
        case .none:
            return "Unable to commit"
        }
    }

    /// Checks if the change is one.
    /// 
    /// If there is only one changed file in list we will return true else
    /// if there is more than one we return false.
    /// 
    /// - Returns: Whether the change is one.
    private func checkIfChangeIsOne() -> Bool {
        return workspace.fileSystemClient?.model?.changed.count == 1
    }

    /// Commits the changes.
    private func commit() {
        let logger: Logger = Logger(subsystem: "com.auroraeditor.vcs", category: "Commit Changes View")

        guard let client = gitClient else {
            logger.fault("No git client!")
            return
        }
        do {
            let changedFiles = (try? client.getChangedFiles().map { $0.fileName }) ?? []
            if !changedFiles.isEmpty {
                if stageAll {
                    try client.stage(files: changedFiles)
                }
                var message = summaryText
                if !descriptionText.isEmpty {
                    message += "\n\n" + descriptionText
                }
                try client.commit(message: message)
            } else {
                logger.info("No changes to commit!")
            }
        } catch let err {
            logger.fault("\(err)")
        }
    }
}

struct CommitChangesView_Previews: PreviewProvider {
    static var previews: some View {
        CommitChangesView(workspace: WorkspaceDocument())
    }
}
