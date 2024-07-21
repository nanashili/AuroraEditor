//
//  CommitChangesView+CommitRules.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2024/07/20.
//  Copyright © 2024 Aurora Company. All rights reserved.
//

import Version_Control

extension CommitChangesView {

    internal func updateRepoRulesCommitMessageFailues(
        forceUpdate: Bool
    ) {
        if forceUpdate {
            let commitContext: CommitContext = CommitContext(
                summary: summaryText,
                description: descriptionText,
                amend: commitToAmend != nil,
                trailers: coAuthorTrailers
            )

            let commitMessage = CommitMessageFormatter().formatCommitMessage(
                directoryURL: workspace.folderURL,
                context: commitContext
            )

            let failures = repoRulesInfo?.commitMessagePatterns.getFailedRules(commitMessage)

            // We end the call here since the failues are nil
            // no need to update the UI state and use resources
            guard let failures = failures else {
                return
            }

            repoRuleCommitMessageFailures = failures
        }
    }
}
