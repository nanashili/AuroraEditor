//
//  WorkflowRuns.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/09/13.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

/// GitHub Actions Workflow Run
struct WorkflowRuns: Codable {
    /// Total count
    let totalCount: Int

    /// Workflow runs
    let workflowRuns: [WorkflowRun]?

    /// Coding keys
    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case workflowRuns = "workflow_runs"
    }
}
