//
//  CommitButton.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2024/07/19.
//  Copyright © 2024 Aurora Company. All rights reserved.
//

import SwiftUI
import OSLog
import Version_Control

enum WarningToDisplay: String {
    case publish
    case commitSigning
    case basic
}

struct CommitButton: View {

    @State
    var summaryText: String

    @State
    var descriptionText: String

    @State
    var branchName: String

    @State
    var commitToAmend: Commit?

    @State
    var showNoWriteAccess: Bool = false

    @State
    var showBranchProtected: Bool = false

    @State
    var repoRulesInfo: RepoRulesInfo?

    @State
    var aheadBehind: IAheadBehind?

    @State
    var repoRuleBranchNameFailures: RepoRulesMetadataFailures = RepoRulesMetadataFailures()

    @State
    var repoRulesEnabled: Bool = false

    @State
    var isCommitting: Bool = false

    @State
    var addedCoAuthors: String

    @State
    var addCoAuthors: Bool

    @State
    var workspaceFolder: URL

    @EnvironmentObject
    private var versionControl: VersionControlModel

    var body: some View {
        VStack {
            renderAmendCommitNotice()
            if versionControl.workspaceProvider == .github {
                renderBranchProtectionsRepoRulesCommitWarning()
            }
            submitButton()
        }
    }

    @ViewBuilder
    private func submitButton() -> some View {
        let isSummaryBlank = summaryText.isEmpty
        let buttonEnabled = (
            canCommit() || canAmend() && !isCommitting && !isSummaryBlank
        )

        Button(action: commitChanges) {
            Spacer()

            HStack {
                if isCommitting {
                    ProgressView()
                }

                buttonText()
                    .foregroundColor(.white)
                    .font(.system(size: 11))
                    .padding(.vertical, 5)
            }

            Spacer()
        }
        .buttonStyle(.borderedProminent)
        .frame(width: .infinity)
        .disabled(buttonEnabled)
    }

    @ViewBuilder
    private func renderAmendCommitNotice() -> some View {
        if commitToAmend != nil {
            CommitWarning(
                warningType: .information,
                warningMessage: .text(
                """
Your changes will modify your **most recent commit**\n
                 Stop amending
                 to make these changes as a new commit.
"""
                )
            )
        } else {
            EmptyView()
        }
    }

    /// Returns the appropriate verb for the button based on the current commit state.
    ///
    /// Returns: A `String` representing either "Amend" or "Commit" depending on the commit state.
    private func buttonVerb() -> String {
        let amendVerb = isCommitting ? "Amending" : "Amend"
        let commitVerb = isCommitting ? "Committing" : "Commit"

        let isAmending = commitToAmend != nil

        return isAmending ? amendVerb : commitVerb
    }

    /// Returns the text for the commit button, including the branch name if applicable.
    ///
    /// Returns: A `String` representing the commit button text.
    private func committingButtonText() -> Text {
        let verb = buttonVerb()

        if branchName.isEmpty {
            return Text(verb)
        }

        return Text("\(verb) to **\(branchName)**")
    }

    /// Returns the text for the button, considering whether it is an amendment.
    ///
    /// Returns: A `String` representing the button text.
    private func buttonText() -> Text {
        let isAmending = commitToAmend != nil

        return isAmending ? buttonTitle() : committingButtonText()
    }

    /// Returns the title for the button, considering whether it is an amendment.
    ///
    /// Returns: A `String` representing the button title.
    func buttonTitle() -> Text {
        let isAmending = commitToAmend != nil

        return Text(isAmending ? "\(buttonVerb()) last commit" : committingButtonTitle())
    }

    /// Returns the title for the commit button, including the branch name if applicable.
    ///
    /// Returns: A `String` representing the commit button title.
    func committingButtonTitle() -> String {
        let verb = buttonVerb()

        if branchName.isEmpty {
            return verb
        }

        return "\(verb) to **\(branchName)**"
    }

    private func canCommit() -> Bool {
        return summaryText.isEmpty
    }

    private func canAmend() -> Bool {
        return commitToAmend != nil && summaryText.isEmpty
    }

    /// Commits the changes.
    private func commitChanges() {
        if shouldWarnForRepoRuleBypass() &&
            versionControl.workspaceProvider == .github &&
            !branchName.isEmpty {
            // TODO: showRepoRulesCommitBypassWarning sheet

        } else {
            createCommit()
        }
    }

    private func createCommit() {
        if !canCommit() && !canAmend() {
            return
        }

        let trailers = getCoAuthorTrailers()
        let commitContent = CommitContext(
            summary: summaryText,
            description: descriptionText,
            amend: commitToAmend != nil,
            trailers: trailers
        )
    }

    private func submitCommit(context: CommitContext) -> Bool {
        do {
            let filesIgnoredByLFS = try LFS().filesNotTrackedByLFS(
                directoryURL: workspaceFolder,
                filePaths: []
            )

            if !filesIgnoredByLFS.isEmpty {
                // TODO: Show oversize popup
                return false
            }

            let message = CommitMessageFormatter().formatCommitMessage(
                directoryURL: workspaceFolder,
                context: context
            )

            let commitResult = try GitCommit().createCommit(
                directoryURL: workspaceFolder,
                message: message,
                files: [],
                amend: context.amend ?? false
            )

            return !commitResult.isEmpty
        } catch {
            return false
        }
    }

    /// Retrieves the list of trailers for co-authors.
    ///
    /// This function checks if co-authors should be added to the commit.
    /// If co-authors are to be added, it constructs a list of `Trailer` objects for each
    /// co-author from the `addedCoAuthors` string. Each `Trailer`
    /// object represents a co-author's information in the format required for Git commits.
    ///
    /// - Returns: An array of `Trailer` objects representing the co-authors.
    /// - Note: If `addCoAuthors` is false, the function returns an empty array.
    private func getCoAuthorTrailers() -> [Trailer] {
        guard addCoAuthors else { return [] }

        let token = "Co-Authored-By"

        let mentionableDictionary = Dictionary(
            uniqueKeysWithValues: versionControl.githubRepositoryMentionables.map { ($0.login, $0) }
        )

        return addedCoAuthors
            .split(separator: " ")
            .compactMap { coAuthor -> Trailer? in
                let login = String(coAuthor.dropFirst())

                guard let author = mentionableDictionary[login] else { return nil }

                let namePart = author.name.map { "\($0) " } ?? ""

                return Trailer(token: token, value: "\(namePart)<\(author.email)>")
            }
    }
}
