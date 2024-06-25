//
//  RepositoriesTableViewController.swift
//  Aurora Editor
//
//  Created by TAY KAI QUAN on 17/8/22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

/// A `NSTableCellView` showing an ``icon`` and a ``label``
final class RepositoriesTableViewCell: StandardTableViewCell {

    /// Initialize the cell
    /// 
    /// - Parameter frameRect: the frame
    /// - Parameter repository: the repository model
    /// - Parameter cellType: the cell type
    init(
        // swiftlint:disable:previous function_body_length
        frame frameRect: NSRect,
        repository: RepositoryModel,
        represents cellType: CellType = .repo,
        item: RepoItem? = nil
    ) {
        super.init(frame: frameRect)

        // Add text and image
        var image = NSImage()
        switch cellType {
        case .repo:
            label.stringValue = "\(repository.repoName ?? "Unknown Repo")"
            if let branches = repository.branches,
               branches.current >= 0, // Ensure the index is non-negative.
               branches.current < branches.contents.count { // Ensure the index is within bounds.
                if let currentBranch = (branches.contents[branches.current] as? RepoBranch)?.name {
                    secondaryLabel.stringValue = "\(currentBranch)"
                } else {
                    secondaryLabel.stringValue = "Unknown Branch"
                }
            } else {
                secondaryLabel.stringValue = "Unknown Branch"
            }

            if let clockImage = NSImage(systemSymbolName: "clock", accessibilityDescription: nil) {
                image = clockImage
            } else {
                // Handle the case where the system image isn't found
                image = NSImage() // Create a default image if needed
            }

        case .branches:
            label.stringValue = "Branches"
            image = NSImage(named: "git.branch")!

        case .recentLocations:
            label.stringValue = "Recent Locations"
            image = NSImage(named: "git.branch")!

        case .tags:
            label.stringValue = "Tags"
            image = NSImage(systemSymbolName: "tag", accessibilityDescription: nil)!

        case .stashedChanges:
            label.stringValue = "Stashed Changes"
            image = NSImage(systemSymbolName: "tray", accessibilityDescription: nil)!

        case .remotes:
            label.stringValue = "Remotes"
            image = NSImage(named: "vault")!

        case .remote:
            label.stringValue = "origin" // TODO: Modifiable remote name
            image = NSImage(named: "vault")!

        case .branch:
            var currentBranch = "Unknown Branch"
            if let branches = repository.branches,
               let unsafeCurrentBranch = branches.contents[branches.current] as? RepoBranch {
                currentBranch = unsafeCurrentBranch.name
            }

            label.stringValue = item?.name ?? "Unknown Branch"
            if label.stringValue == currentBranch {
                secondaryLabel.stringValue = "*"
            }
            image = NSImage(named: "git.branch")!

        case .tag:
            label.stringValue = item?.name ?? "Unknown Tag"
            image = NSImage(systemSymbolName: "tag", accessibilityDescription: nil)!

        case .change:
            label.stringValue = item?.name ?? "Unknown Change"
            image = NSImage(systemSymbolName: "tray", accessibilityDescription: nil)!
        }
        icon.image = image
        icon.contentTintColor = .gray

        if cellType == .repo {
            self.secondaryLabelRightAlignmed = false
        }
        resizeSubviews(withOldSize: .zero)
    }

    /// The type of cell
    enum CellType {
        // groups

        /// Repository
        case repo

        /// Branches
        case branches

        /// Recent locations
        case recentLocations

        /// Tags
        case tags

        /// Stashed changes
        case stashedChanges

        /// Remotes
        case remotes

        /// Single remote
        case remote

        // items

        /// Branch
        case branch

        /// Tag
        case tag

        /// Change
        case change
    }

    /// Initialize the cell
    required init?(coder: NSCoder) {
        fatalError("""
            init?(coder: NSCoder) isn't implemented on `RepositoriesTableViewCell`.
            Please use `.init(frame: NSRect)
            """)
    }
}
