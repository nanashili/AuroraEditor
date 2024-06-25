//
//  GitlabCommit.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/03/31.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

@available(*, deprecated, renamed: "VersionControl", message: "This will be deprecated in favor of the new VersionControl Remote SDK APIs.")
/// Gitlab Commit
open class GitlabCommit: Codable {

    /// Identifier
    open var id: String

    /// Short Identifier
    open var shortID: String?

    /// Title
    open var title: String?

    /// Author Name
    open var authorName: String?

    /// Author Email
    open var authorEmail: String?

    /// Committer Name
    open var committerName: String?

    /// Committer Email
    open var committerEmail: String?

    /// Created At
    open var createdAt: Date?

    /// Message
    open var message: String?

    /// Committed Date
    open var committedDate: Date?

    /// Authored Date
    open var authoredDate: Date?

    /// Parent Identifiers
    open var parentIDs: [String]?

    /// Stats
    open var stats: CommitStats?

    /// Status
    open var status: String?

    /// Coding Keys
    enum CodingKeys: String, CodingKey {
        case id
        case shortID = "short_id"
        case title
        case authorName = "author_name"
        case authorEmail = "author_email"
        case committerName = "committer_name"
        case committerEmail = "committer_email"
        case createdAt = "created_at"
        case message
        case committedDate = "committed_date"
        case authoredDate = "authored_date"
        case parentIDs = "parent_ids"
        case stats
        case status
    }
}

/// Commit Stats
open class CommitStats: Codable {

    /// Additions
    open var additions: Int?

    /// Deletions
    open var deletions: Int?

    /// Total
    open var total: Int?

    /// Coding Keys
    enum CodingKeys: String, CodingKey {
        case additions
        case deletions
        case total
    }
}

/// Commit Diff
open class CommitDiff: Codable {

    /// Diff
    open var diff: String?

    /// New Path
    open var newPath: String?

    /// Old Path
    open var oldPath: String?

    /// A Mode
    open var aMode: String?

    /// B Mode
    open var bMode: String?

    /// New File
    open var newFile: Bool?

    /// Renamed File
    open var renamedFile: Bool?

    /// Deleted File
    open var deletedFile: Bool?

    enum CodingKeys: String, CodingKey {
        case diff
        case newPath = "new_path"
        case oldPath = "old_path"
        case aMode = "a_mode"
        case bMode = "b_mode"
        case newFile = "new_file"
        case renamedFile = "renamed_file"
        case deletedFile = "deleted_file"
    }
}

/// Commit Comment
open class CommitComment: Codable {

    /// Note
    open var note: String?

    /// Author
    open var author: GitlabUser?

    /// Coding Keys
    enum CodingKeys: String, CodingKey {
        case note
        case author
    }
}

/// Commit Status
open class CommitStatus: Codable {

    /// Status
    open var status: String?

    /// Created At
    open var createdAt: Date?

    /// Started At
    open var startedAt: Date?

    /// Name
    open var name: String?

    /// Allow Failure
    open var allowFailure: Bool?

    /// Author
    open var author: GitlabUser?

    /// Status Description
    open var statusDescription: String?

    /// SHA
    open var sha: String?

    /// Target URL
    open var targetURL: URL?

    /// Finished At
    open var finishedAt: Date?

    /// Identifier
    open var id: Int?

    /// Reference
    open var ref: String?

    /// Coding Keys
    enum CodingKeys: String, CodingKey {
        case status
        case createdAt = "created_at"
        case startedAt = "started_at"
        case name
        case allowFailure = "allow_failure"
        case author
        case statusDescription = "description"
        case sha
        case targetURL = "target_url"
        case finishedAt = "finished_at"
        case id
        case ref
    }
}

public extension GitlabAccount {

    /// Get a list of repository commits in a project.
    /// - parameter id: The ID of a project or namespace/project name owned by the authenticated user.
    /// - parameter refName: The name of a repository branch or tag or if not given the default branch.
    /// - parameter since: Only commits after or in this date will be returned in ISO 8601 format YYYY-MM-DDTHH:MM:SSZ.
    /// - parameter until: Only commits before or in this date will be returned in ISO 8601 format YYYY-MM-DDTHH:MM:SSZ.
    /// - parameter completion: Callback for the outcome of the fetch.
    ///
    /// - returns: URLSessionDataTaskProtocol
    func commits(_ session: GitURLSession = URLSession.shared,
                 id: String,
                 refName: String = "",
                 since: String = "",
                 until: String = "",
                 completion: @escaping (
                    _ response: Result<GitlabCommit, Error>) -> Void) -> URLSessionDataTaskProtocol? {

                        let router = CommitRouter.readCommits(self.configuration,
                                                              id: id,
                                                              refName: refName,
                                                              since: since,
                                                              until: until)

                        return router.load(session,
                                           dateDecodingStrategy: .formatted(Time.rfc3339DateFormatter),
                                           expectedResultType: GitlabCommit.self) { json, error in

                            if let error = error {
                                completion(Result.failure(error))
                            }

                            if let json = json {
                                completion(Result.success(json))
                            }
                        }
                    }

    /// Get a specific commit in a project.
    /// 
    /// - parameter id: The ID of a project or namespace/project name owned by the authenticated user.
    /// - parameter sha: The commit hash or name of a repository branch or tag.
    /// - parameter completion: Callback for the outcome of the fetch.
    /// 
    /// - returns: URLSessionDataTaskProtocol
    func commit(_ session: GitURLSession = URLSession.shared,
                id: String,
                sha: String,
                completion: @escaping (
                    _ response: Result<GitlabCommit, Error>) -> Void) -> URLSessionDataTaskProtocol? {

                        let router = CommitRouter.readCommit(self.configuration, id: id, sha: sha)

                        return router.load(session,
                                           dateDecodingStrategy: .formatted(Time.rfc3339DateFormatter),
                                           expectedResultType: GitlabCommit.self) { json, error in

                            if let error = error {
                                completion(Result.failure(error))
                            }

                            if let json = json {
                                completion(Result.success(json))
                            }
                        }
                    }

    /// Get a diff of a commit in a project.
    /// 
    /// - parameter id: The ID of a project or namespace/project name owned by the authenticated user.
    /// - parameter sha: The commit hash or name of a repository branch or tag.
    /// - parameter completion: Callback for the outcome of the fetch.
    ///
    /// - returns: URLSessionDataTaskProtocol
    func commitDiffs(_ session: GitURLSession = URLSession.shared,
                     id: String,
                     sha: String,
                     completion: @escaping (
                        _ response: Result<CommitDiff, Error>) -> Void) -> URLSessionDataTaskProtocol? {

                            let router = CommitRouter.readCommitDiffs(self.configuration, id: id, sha: sha)

                            return router.load(session,
                                               dateDecodingStrategy: .formatted(Time.rfc3339DateFormatter),
                                               expectedResultType: CommitDiff.self) { json, error in

                                if let error = error {
                                    completion(Result.failure(error))
                                }

                                if let json = json {
                                    completion(Result.success(json))
                                }
                            }
                        }

    /// Get the comments of a commit in a project.
    /// 
    /// - parameter id: The ID of a project or namespace/project name owned by the authenticated user.
    /// - parameter sha: The commit hash or name of a repository branch or tag.
    /// - parameter completion: Callback for the outcome of the fetch.
    ///
    /// - returns: URLSessionDataTaskProtocol
    func commitComments(_ session: GitURLSession = URLSession.shared,
                        id: String,
                        sha: String,
                        completion: @escaping (
                            _ response: Result<CommitComment, Error>) -> Void) -> URLSessionDataTaskProtocol? {

                                let router = CommitRouter.readCommitComments(self.configuration, id: id, sha: sha)

                                return router.load(session,
                                                   dateDecodingStrategy: .formatted(Time.rfc3339DateFormatter),
                                                   expectedResultType: CommitComment.self) { json, error in

                                    if let error = error {
                                        completion(Result.failure(error))
                                    }

                                    if let json = json {
                                        completion(Result.success(json))
                                    }
                                }
                            }

    /// Get the statuses of a commit in a project.
    ///
    /// - parameter id: The ID of a project or namespace/project name owned by the authenticated user.
    /// - parameter sha: The commit hash or name of a repository branch or tag.
    /// - parameter ref: The name of a repository branch or tag or, if not given, the default branch.
    /// - parameter stage: Filter by build stage, e.g. `test`.
    /// - parameter name: Filter by job name, e.g. `bundler:audit`.
    /// - parameter all: Return all statuses, not only the latest ones. (Boolean value)
    /// - parameter completion: Callback for the outcome of the fetch.
    ///
    /// - returns: URLSessionDataTaskProtocol
    func commitStatuses(_ session: GitURLSession = URLSession.shared,
                        id: String,
                        sha: String,
                        ref: String = "",
                        stage: String = "",
                        name: String = "",
                        all: Bool = false,
                        completion: @escaping (
                            _ response: Result<CommitStatus, Error>) -> Void) -> URLSessionDataTaskProtocol? {

                                let router = CommitRouter.readCommitStatuses(self.configuration, id: id,
                                                                             sha: sha,
                                                                             ref: ref,
                                                                             stage: stage,
                                                                             name: name,
                                                                             all: all)

                                return router.load(session,
                                                   dateDecodingStrategy: .formatted(Time.rfc3339DateFormatter),
                                                   expectedResultType: CommitStatus.self) { json, error in

                                    if let error = error {
                                        completion(Result.failure(error))
                                    }

                                    if let json = json {
                                        completion(Result.success(json))
                                    }
                                }
                            }
}
