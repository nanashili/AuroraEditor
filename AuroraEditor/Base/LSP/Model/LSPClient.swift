//
//  LSPClient.swift
//  Aurora Editor
//
//  Created by Pavel Kasila on 16.04.22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

/// A LSP client to handle Language Server process
public final class LSPClient {
    /// Executable URL
    private let executable: URL

    /// Workspace URL
    private let workspace: URL

    /// Process
    private let process: Process

    /// Initialize new LSP client
    /// 
    /// - Parameters:
    ///   - executable: Executable of the Language Server to be run
    ///   - workspace: Workspace's URL
    ///   - arguments: Additional arguments from `CELSPArguments` in `Info.plist` of the Language Server bundle
    /// 
    /// - Returns: LSP client
    /// 
    /// - Throws: Error if process cannot be run
    public init(_ executable: URL, workspace: URL, arguments: [String]?) throws {
        self.executable = executable
        try FileManager.default.setAttributes([.posixPermissions: 0o555], ofItemAtPath: executable.path)
        self.workspace = workspace
        self.process = try Process.run(executable, arguments: arguments ?? ["--stdio"], terminationHandler: nil)
    }

    /// Close the process
    public func close() {
        process.terminate()
    }
}
