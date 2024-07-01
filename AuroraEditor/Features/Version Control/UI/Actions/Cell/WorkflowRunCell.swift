//
//  WorkflowRunCell.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/09/13.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI
import Version_Control

struct WorkflowRunCell: View {

    @State
    var workflowRun: WorkflowRun

    var body: some View {
        HStack {
            switch workflowRun.conclusion {
            case "in_progress":
                Image(systemName: "hourglass.circle")
                    .symbolRenderingMode(.multicolor)
                    .accessibilityHidden(true)
            case "success":
                Image(systemName: "checkmark.diamond.fill")
                    .symbolRenderingMode(.multicolor)
                    .accessibilityHidden(true)
            case "timed_out":
                Image(systemName: "exclamationmark.arrow.circlepath")
                    .symbolRenderingMode(.hierarchical).accessibilityHidden(true)
            case "failure":
                Image(systemName: "xmark.diamond.fill")
                    .symbolRenderingMode(.multicolor)
                    .accessibilityHidden(true)
            case "queued":
                Image(systemName: "timer.circle")
                    .symbolRenderingMode(.hierarchical)
                    .accessibilityHidden(true)
            case "cancelled":
                Image(systemName: "xmark.diamond")
                    .symbolRenderingMode(.hierarchical)
                    .accessibilityHidden(true)
            default:
                Image(systemName: "diamond")
                    .accessibilityHidden(true)
            }

            Text(getCommitName())
                .font(.system(size: 12))

            Text(workflowRun.name)
                .font(.system(size: 11))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 10)
    }

    private func getCommitName() -> String {
        return workflowRun.headCommit.message.split(separator: "\n")[0].description
    }
}
