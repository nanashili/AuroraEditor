//
//  FileItemFileSystemFunctions.swift
//  Aurora Editor
//
//  Created by TAY KAI QUAN on 6/8/22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation
import SwiftUI

/// An extension to the `FileItem` class providing high-level file management functions within a filesystem structure.
public typealias FileItem = FileSystemClient.FileItem

extension FileItem {
    /// Creates a new folder within the directory of this file item or alongside it.
    /// The folder is created at the nearest folder level or inside the current folder if it's a directory.
    ///
    /// - Parameter folderName: The name of the folder to create.
    ///
    /// The function first determines the base directory for the new folder based 
    /// on whether the current file item is a folder itself. It then attempts to create a new 
    /// folder with the given name, appending a number to the folder name if a
    /// folder with the same name already exists.
    public func addFolder(folderName: String,
                          permissions: mode_t = 0o777) {
        // Determine initial folder path based on whether the current item is a folder
        let basePath = self.isFolder ? self.url.path : self.url.deletingLastPathComponent().path
        var folderPath = "\(basePath)/\(folderName)"
        var fileNumber = 0

        // Check if the folder exists and update the name to avoid collisions
        while LowLevelFileManager().fileExists(atPath: folderPath) {
            fileNumber += 1
            folderPath = "\(basePath)/\(folderName)\(fileNumber)"
        }

        // Try to create the folder with specified permissions, handling errors without crashing
        LowLevelFileManager().createDirectory(atPath: folderPath)
    }

    /// Creates a file within the current directory or project main directory.
    /// This method also determines the most common file extension within the directory to append to the new file.
    ///
    /// - Parameter fileName: The base name for the new file, without an extension.
    ///
    /// The function computes the most common file extension in the current directory and appends it to the file name.
    /// If a file with the same name exists, it appends a number to ensure uniqueness before creating the file.
    public func addFile(fileName: String) {
        // Determine the most common file extension in the current directory
        let fileExtensions = determineCommonExtensions()
        let idealExtension = fileExtensions.max(by: { $0.value < $1.value })?.key ?? ""

        // Prepare the initial file path
        let baseFolderPath = nearestFolder.path  // Assuming nearestFolder is a URL
        var filePath = "\(baseFolderPath)/\(fileName)\(idealExtension)"

        // Avoid file name collision by appending a number if necessary
        var fileNumber = 0
        while LowLevelFileManager().fileExists(atPath: filePath) {
            fileNumber += 1
            filePath = "\(baseFolderPath)/\(fileName)\(fileNumber)\(idealExtension)"
        }

        // Create the file using low-level API
        LowLevelFileManager().createFile(atPath: filePath)
    }

    /// Deletes this file item from its current location.
    /// A confirmation dialog is shown to the user before the file is permanently removed.
    ///
    /// This function also has to account for how the file system can change outside of the editor.
    public func delete() {
        // This function also has to account for how the
        // - file system can change outside of the editor
        let deleteConfirmation = NSAlert()
        let message = "\(self.fileName)\(self.isFolder ? " and its children" : "")"
        deleteConfirmation.messageText = "Do you want to move \(message) to the bin?"
        deleteConfirmation.alertStyle = .critical
        deleteConfirmation.addButton(withTitle: "Delete")
        deleteConfirmation.buttons.last?.hasDestructiveAction = true
        deleteConfirmation.addButton(withTitle: "Cancel")
        if deleteConfirmation.runModal() == .alertFirstButtonReturn { // "Delete" button
            if LowLevelFileManager().fileExists(atPath: self.url.path) {
                LowLevelFileManager().removeFile(atPath: self.url.relativePath)
            }
        }
    }

    /// Duplicates this file item within its current directory, creating a copy with a unique name.
    ///
    /// Generates a unique file name based on the current file name and copies the file to the same directory.
    /// If the file system state changes or an error occurs during copying, the operation fails with an error.
    public func duplicate() {
        LowLevelFileManager().duplicate(item: url)
    }

    /// Moves the file item to a specified location, creating any necessary parent directories.
    /// - Parameter newLocation: The target URL to which the file item should be moved.
    /// - Throws: An error if the file could not be moved or if required directories could not be created.
    public func move(to newLocation: URL) throws {
        let sourcePath = self.url.path
        let targetPath = newLocation.path

        // Check if the target file already exists
        if LowLevelFileManager().fileExists(atPath: targetPath) {
            Log.error("Move operation aborted: A file already exists at the target location \(targetPath)")
            throw NSError(domain: "FileMoveError",
                          code: 1,
                          userInfo: [NSLocalizedDescriptionKey: "Target file already exists."])
        }

        // Attempt to create necessary parent directories
        try createMissingParentDirectory(for: newLocation.deletingLastPathComponent())

        // Perform the move using rename system call
        let movedSuccessfully = LowLevelFileManager().moveItem(fromPath: sourcePath,
                                                               toPath: targetPath)
        if !movedSuccessfully {
            let errorMessage = String(cString: strerror(errno))
            Log.error("Failed to move file: \(errorMessage)")
            throw NSError(domain: "FileMoveError",
                          code: Int(errno),
                          userInfo: [NSLocalizedDescriptionKey: "Failed to move file: \(errorMessage)"])
        }

        Log.info("Successfully moved file \(self.url.debugDescription) to \(newLocation.debugDescription)")
    }

    private func createMissingParentDirectory(for path: URL) throws {
        var isDir: ObjCBool = false
        let parentPath = path.path

        if !FileManager.default.fileExists(atPath: parentPath, isDirectory: &isDir) {
            if mkdir(parentPath, 0777) != 0 {  // Create the directory with full permissions
                let errorMessage = String(cString: strerror(errno))
                Log.error("Failed to create directory: \(errorMessage)")
                throw NSError(domain: "DirectoryCreationError",
                              code: Int(errno),
                              userInfo: [NSLocalizedDescriptionKey: "Failed to create directory: \(errorMessage)"])
            }
        } else if !isDir.boolValue {
            // The path exists and is not a directory, which is an error
            throw NSError(domain: "DirectoryCreationError",
                          code: 2,
                          userInfo: [NSLocalizedDescriptionKey: "A non-directory file exists at \(parentPath)"])
        }
    }

    // MARK: - Helper Functions

    /// Determines the most common file extensions among the siblings of this file item.
    ///
    /// - Returns: A dictionary mapping file extensions to their frequencies.
    ///
    /// This method scans the files in the same directory as this file
    /// item and counts the occurrences of each file extension.
    private func determineCommonExtensions() -> [String: Int] {
        let siblings = (self.isFolder ? [self] : parent?.flattenedSiblings(height: 2, ignoringFolders: true)) ?? []
        var fileExtensions: [String: Int] = [:]

        for child in siblings where !child.isFolder {
            let childFileName = child.fileName(typeHidden: false)
            let extensionIndex = childFileName.lastIndex(of: ".") ?? childFileName.endIndex
            let childFileExtension = String(childFileName.suffix(from: extensionIndex).dropFirst())
            fileExtensions[childFileExtension, default: 0] += 1
        }

        return fileExtensions
    }

    /// Computes the nearest folder for the current file item. It either returns the item's own URL if it's a folder,
    /// or the parent directory's URL if it's not a folder. Additionally, it validates the resulting URL to ensure
    /// it points to a valid folder on the filesystem.
    public var nearestFolder: URL {
        let folderURL = self.isFolder ? self.url : self.url.deletingLastPathComponent()

        // Use the stat function to check if the path points to a directory
        var statInfo = stat()
        if stat(folderURL.path, &statInfo) == 0 {
            if (statInfo.st_mode & S_IFMT) == S_IFDIR {
                // The path is a directory
                return folderURL
            } else {
                // The path is not a directory
                Log.warning("The computed nearest folder URL is not a valid directory: \(folderURL.path)")
                // Fallback to a default directory (e.g., Document directory)
                return URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory,
                                                                                .userDomainMask, true).first ?? "/")
            }
        } else {
            // Error checking the file stats
            Log.error("Failed to retrieve file statistics for \(folderURL.path): \(String(cString: strerror(errno)))")
            return URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory,
                                                                            .userDomainMask, true).first ?? "/")
        }
    }
}
