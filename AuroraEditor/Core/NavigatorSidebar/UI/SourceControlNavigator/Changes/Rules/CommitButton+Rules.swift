//
//  CommitButton+Rules.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2024/07/20.
//  Copyright © 2024 Aurora Company. All rights reserved.
//

import Foundation
import SwiftUI

extension CommitButton {
    @ViewBuilder
    internal func renderBranchProtectionsRepoRulesCommitWarning() -> some View { // swiftlint:disable:this function_body_length line_length
        let repoRuleWarningToDisplay = determineRepoRuleWarningToDisplay()

        if showNoWriteAccess {
            let markdownText = """
"You don't have write access to **\(branchName)**. Want to create a fork?"
"""
            let tappableText = "Want to create a fork"
            let tappableRange = (markdownText as NSString).range(of: tappableText)

            CommitWarning(
                warningType: .warning,
                warningMessage: .view(
                    MarkdownTextViewRepresentable(
                        markdownText: markdownText,
                        tappableRanges: [tappableRange],
                        onTap: { _ in
                        }
                    )
                )
            )
        } else if showBranchProtected {
            if branchName.isEmpty {
                // If the branch is empty that means we haven't loaded the tip yet or
                // we're on a detached head. We shouldn't ever end up here with
                // showBranchProtected being true without a branch but who knows
                // what fun and exciting edge cases the future might hold
                EmptyView()
            }

            CommitWarning(
                warningType: .warning,
                warningMessage: .view(
                    MarkdownTextViewRepresentable(
                        markdownText: """
"**\(branchName)** is a protected branch. Want to switch branches?"
""",
                        tappableRanges: [],
                        onTap: { _ in
                        }
                    )
                )
            )
        } else if repoRuleWarningToDisplay == .publish {
            let canBypass = canBypassRepoRule(for: .publish)

            let markdownText = """
The branch name **\(branchName)** fails one or more rules that
\(canBypass ? "would" : "will") prevent it from being published
\(canBypass ? ", but you can bypass them. Procees with caution!" : "")
\(!canBypass ? ". Want to switch branches?" : "")
"""
            let tappableText = "Want to switch branches"
            let tappableRange = (markdownText as NSString).range(of: tappableText)

            CommitWarning(
                warningType: canBypass ? .warning : .error,
                warningMessage: .view(
                    MarkdownTextViewRepresentable(
                        markdownText: markdownText,
                        tappableRanges: [tappableRange],
                        onTap: { _ in
                        })
                )
            )
        } else if repoRuleWarningToDisplay == .commitSigning {
            let canBypass = canBypassRepoRule(for: .commitSigning)

            let markdownText = "One or more rules apply to the branch **\(branchName)** that require signed commits \(canBypass ? ", but you can bypass them. Proceed with caution!" : "") \(!canBypass ? "." : "") [Learn more about commit signing.](https://docs.github.com/authentication/managing-commit-signature-verification/signing-commits)" // swiftlint:disable:this line_length

            CommitWarning(
                warningType: canBypass ? .warning : .error,
                warningMessage: .view(
                    MarkdownTextViewRepresentable(
                        markdownText: markdownText,
                        tappableRanges: [],
                        onTap: { _ in
                        }
                    )
                )
            )
        } else if repoRuleWarningToDisplay == .basic {
            let canBypass = canBypassRepoRule(for: .basic)

            let markdownText = """
One or more rules apply to the branch **\(branchName)** that
\(canBypass ? "would" : "will") prevent pushing
\(canBypass ? ", but you can bypass them. Proceed with caution!" : "")
\(!canBypass ? ". Want to switch branches?" : "")
"""
            let tappableText = "Want to switch branches"
            let tappableRange = (markdownText as NSString).range(of: tappableText)

            CommitWarning(
                warningType: canBypass ? .warning : .error,
                warningMessage: .view(
                    MarkdownTextViewRepresentable(
                        markdownText: markdownText,
                        tappableRanges: [tappableRange],
                        onTap: { _ in
                        }
                    )
                )
            )
        } else {
            EmptyView()
        }
    }

    private func determineRepoRuleWarningToDisplay() -> WarningToDisplay? {
        var ruleEnforcementStatuses: [WarningToDisplay: RepoRuleEnforced] = [:]
        var repoRuleWarningToDisplay: WarningToDisplay?

        if repoRulesEnabled {
            if aheadBehind == nil && !branchName.isEmpty {
                if repoRulesInfo?.creationRestricted == .enforced(true) ||
                    repoRuleBranchNameFailures.status == .fail {
                    ruleEnforcementStatuses[.publish] = .enforced(true)
                } else if repoRulesInfo?.creationRestricted == .bypass ||
                            repoRuleBranchNameFailures.status == .bypass {
                    ruleEnforcementStatuses[.publish] = .bypass
                } else {
                    ruleEnforcementStatuses[.publish] = .enforced(false)
                }
            }

            ruleEnforcementStatuses[.commitSigning] = repoRulesInfo?.signedCommitsRequired
            ruleEnforcementStatuses[.basic] = repoRulesInfo?.basicCommitWarning

            for (key, value) in ruleEnforcementStatuses {
                switch value {
                case .enforced(let isEnforced) where isEnforced == true:
                    repoRuleWarningToDisplay = key
                default:
                    break
                }
            }

            if repoRuleWarningToDisplay == nil {
                for (key, value) in ruleEnforcementStatuses {
                    switch value {
                    case .bypass:
                        repoRuleWarningToDisplay = key
                    default:
                        break
                    }
                }
            }
        }

        return repoRuleWarningToDisplay
    }

    private func canBypassRepoRule(for warning: WarningToDisplay) -> Bool {
        var canBypass = false

        switch warning {
        case .publish:
            if repoRulesInfo?.signedCommitsRequired == .bypass {
                canBypass = true
            }
        case .commitSigning:
            if repoRulesInfo?.signedCommitsRequired == .bypass {
                canBypass = true
            }
        case .basic:
            if repoRulesInfo?.basicCommitWarning == .bypass {
                canBypass = true
            }
        }

        return canBypass
    }

    private func hasRepoRuleFailure() -> Bool {
        if !repoRulesEnabled {
            return false
        }

        return repoRulesInfo?.basicCommitWarning == .enforced(true) ||
        repoRulesInfo?.signedCommitsRequired == .enforced(true) ||
        repoRulesInfo?.pullRequestRequired == .enforced(true) ||
        (aheadBehind == nil && repoRulesInfo?.creationRestricted == .enforced(true) ||
         repoRuleBranchNameFailures.status == .fail)
    }

    /// If true, then rules exist for the branch but the user is bypassing all of them.
    /// Used to display a confirmation prompt.
    internal func shouldWarnForRepoRuleBypass() -> Bool {
        if repoRulesEnabled {
            return false
        }

        // if all rules pass, then nothing to warn about,
        // if at least one rule fails, then the user won't hit this
        // in the first place because the button will be disabled,
        // therefore, only need to check if any single
        // value is 'bypass'.
        if repoRulesInfo?.basicCommitWarning == .enforced(true) ||
            repoRulesInfo?.signedCommitsRequired == .enforced(true) ||
            repoRulesInfo?.pullRequestRequired == .enforced(true) {
            return true
        }

        return aheadBehind != nil &&
        !branchName.isEmpty &&
        (repoRulesInfo?.creationRestricted == .bypass ||
         repoRuleBranchNameFailures.status == .bypass)
    }
}
