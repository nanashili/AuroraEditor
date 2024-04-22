//
//  FileSystemClient.swift
//  Aurora Editor
//
//  Created by TAY KAI QUAN on 13/8/22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Combine
import Foundation

/// File System Client
public class FileSystemClient {

    // MARK: - Properties

    // TODO: Turn into class variables
    /// Callback function that is run when a change is detected in the file system.
    /// This usually contains a `reloadData` function.
    public var onRefresh: () -> Void = {}

    // Variables for the outside to interface with
    /// Get Files
    public var getFiles: AnyPublisher<[FileItem], Never> =
    CurrentValueSubject<[FileItem], Never>([]).eraseToAnyPublisher()
    /// Folder URL
    public var folderURL: URL?
    /// Version Control Model
    public var model: SourceControlModel?

    // These should be private but some functions need them public :(
    /// File Manager
    public var fileManager: FileManager
    /// Ignored files and folders
    public var ignoredFilesAndFolders: [String]
    /// Workspace item
    public let workspaceItem: FileItem
    /// Flattened file items
    public var flattenedFileItems: [String: FileItem]
    /// Subject
    private var subject = CurrentValueSubject<[FileItem], Never>([])

    let flattenedFileItemsQueue = DispatchQueue(label: "com.auroraeditor.flattenedFileItemsQueue")

    var watcher: FileSystemWatcher?

    // MARK: - Initializer

    /// Init
    /// - Parameters:
    ///   - fileManager: file manager
    ///   - folderURL: Folder URL
    ///   - ignoredFilesAndFolders: ignored files and folders
    ///   - model: Version control model
    public init(fileManager: FileManager,
                folderURL: URL,
                ignoredFilesAndFolders: [String],
                model: SourceControlModel?) {
        self.fileManager = fileManager
        self.folderURL = folderURL
        self.ignoredFilesAndFolders = ignoredFilesAndFolders
        self.model = model

        // workspace fileItem
        workspaceItem = FileItem(url: folderURL, children: [])
        flattenedFileItems = [workspaceItem.id: workspaceItem]

        self.getFiles = subject
            .handleEvents(receiveCancel: {
                for item in self.flattenedFileItems.values {
                    item.fileSystemClient?.watcher?.stopWatching()
                }
            })
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()

        workspaceItem.fileSystemClient = self
        handleFileChange(file: workspaceItem,
                         event: .write)
        setupWatcher(projectPath: folderURL.path, file: workspaceItem)
    }

    // MARK: - Methods

    /// A function that, given a file's path, returns a `FileItem` if it exists
    /// within the scope of the `FileSystemClient`.
    /// - Parameter id: The file's full path
    /// - Returns: The file item corresponding to the file
    public func getFileItem(_ id: String) throws -> FileItem {
        guard let item = flattenedFileItems[id] else {
            throw FileSystemClientError.fileNotExist
        }

        return item
    }

    /// Usually run when the owner of the `FileSystemClient` doesn't need it anymore.
    /// This de-inits most functions in the `FileSystemClient`, so that in case it isn't de-init'd it does not use up
    /// significant amounts of RAM.
    public func cleanUp() {
        workspaceItem.children = []
        watcher?.stopWatching()
        flattenedFileItems = [workspaceItem.id: workspaceItem]
        Log.info("Cleaned up watchers and file items")
    }

    // Note: Don't use the `Log` here, it throws the following:
    // type of expression is ambiguous without a type annotation
    // fucking Xcode!
    func setupWatcher(projectPath: String = "", file: FileItem) {
        watcher = FileSystemWatcher(path: projectPath, onFileChange: { _, event in
            self.handleFileChange(file: file, event: event)
        })
    }

    func handleFileChange(file: FileItem,
                          event: DispatchSource.FileSystemEvent) {
        _ = try? rebuildFiles(fromItem: file,
                              event: event)

        subject.send(workspaceItem.children ?? [])
        DispatchQueue.main.async {
            self.onRefresh()
        }
        self.listenForGitChanges()
    }

    // TODO: Could be improved
    func listenForGitChanges() {
        DispatchQueue.main.async {
            self.model?.reloadChangedFiles()
        }
        for changedFile in (model?.changed ?? []) {
            flattenedFileItems[changedFile.id]?.gitStatus = changedFile.gitStatus
        }
    }

    // MARK: - Error Enum

    enum FileSystemClientError: Error {
        case fileNotExist
    }
}
