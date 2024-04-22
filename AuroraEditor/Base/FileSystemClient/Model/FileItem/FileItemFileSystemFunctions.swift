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
    public func addFolder(folderName: String) {
        // Determine initial folder URL based on whether the current item is a folder
        let baseFolderUrl = self.isFolder ? self.url : self.url.deletingLastPathComponent()
        var folderUrl = baseFolderUrl.appendingPathComponent(folderName)
        var fileNumber = 0

        // Check if the folder exists and update the name to avoid collisions
        while FileItem.fileManger.fileExists(atPath: folderUrl.path) {
            fileNumber += 1
            folderUrl = baseFolderUrl.appendingPathComponent("\(folderName)\(fileNumber)")
        }

        // Try to create the folder, handling errors without crashing
        do {
            try FileItem.fileManger.createDirectory(at: folderUrl,
                                                    withIntermediateDirectories: true,
                                                    attributes: nil)
        } catch {
            Log.error("Error creating directory at \(folderUrl.path): \(error)")
        }
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

        // Prepare the initial file URL
        let baseFolderUrl = nearestFolder
        var fileUrl = baseFolderUrl.appendingPathComponent("\(fileName)\(idealExtension)")

        // Avoid file name collision by appending a number if necessary
        var fileNumber = 0
        while FileItem.fileManger.fileExists(atPath: fileUrl.path) {
            fileNumber += 1
            fileUrl = baseFolderUrl.appendingPathComponent("\(fileName)\(fileNumber)\(idealExtension)")
        }

        // Create the file
        FileItem.fileManger.createFile(atPath: fileUrl.path,
                                       contents: nil,
                                       attributes: [FileAttributeKey.creationDate: Date()])
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
            if FileItem.fileManger.fileExists(atPath: self.url.path) {
                do {
                    try FileItem.fileManger.removeItem(at: self.url)
                } catch {
                    fatalError(error.localizedDescription)
                }
            }
        }
    }

    /// Duplicates this file item within its current directory, creating a copy with a unique name.
    ///
    /// Generates a unique file name based on the current file name and copies the file to the same directory.
    /// If the file system state changes or an error occurs during copying, the operation fails with an error.
    public func duplicate() {
        var proposedUrl = url
        let fileManager = FileItem.fileManger

        // Generate a unique file name
        let uniqueFileName = generateUniqueFileName(for: proposedUrl)
        proposedUrl.deleteLastPathComponent()
        proposedUrl.appendPathComponent(uniqueFileName)

        Log.info("Duplicating file to \(proposedUrl)")

        if fileManager.fileExists(atPath: url.path) {
            do {
                try fileManager.copyItem(at: url, to: proposedUrl)
            } catch {
                Log.fault("Error at \(self.url.path) to \(proposedUrl.path)")
                fatalError(error.localizedDescription)
            }
        }
    }

    /// Moves the file item to a specified location, creating any necessary parent directories.
    /// - Parameter newLocation: The target URL to which the file item should be moved.
    /// - Throws: An error if the file could not be moved or if required directories could not be created.
    public func move(to newLocation: URL) throws {
        guard !FileItem.fileManger.fileExists(atPath: newLocation.path) else {
            Log.error("Move operation aborted: A file already exists at the target location \(newLocation.path)")
            throw NSError(domain: "FileMoveError",
                          code: 1,
                          userInfo: [NSLocalizedDescriptionKey: "Target file already exists."])
        }

        // Attempt to create necessary parent directories
        try createMissingParentDirectory(for: newLocation.deletingLastPathComponent())

        do {
            Log.info("Moving file \(self.url.debugDescription) to \(newLocation.debugDescription)")
            try FileItem.fileManger.moveItem(at: self.url, to: newLocation)
        } catch {
            Log.error("Failed to move file: \(error.localizedDescription)")
            throw error
        }
    }

    // MARK: - Helper Functions

    /// Generates a unique filename based on an existing URL, intelligently
    /// incrementing a counter within the filename if necessary.
    /// This function checks for an existing pattern (e.g., "untitled (1).swift") and 
    /// increments the number within parentheses to avoid file naming conflicts.
    ///
    /// - Parameter url: The URL of the file for which a unique name is being generated.
    /// - Returns: A unique filename as a `String` based on the original filename and path,
    ///            with a number incremented in parentheses to resolve any conflicts.
    private func generateUniqueFileName(for url: URL) -> String {
        let fileManager = FileItem.fileManger
        let fullPath = url.deletingPathExtension().lastPathComponent
        let extensionPart = url.pathExtension.isEmpty ? "" : ".\(url.pathExtension)"

        // Regular expression to find a number enclosed
        // in parentheses at the end of the filename
        do {
            let regex = try NSRegularExpression(pattern: "\\s*\\((\\d+)\\)$")
            let nsRange = NSRange(fullPath.startIndex..., in: fullPath)

            // Search for the first match
            if let match = regex.firstMatch(in: fullPath, options: [], range: nsRange) {
                // Convert NSRange to Range<String.Index>
                if let range = Range(match.range, in: fullPath),
                   let numberRange = Range(match.range(at: 1), in: fullPath) {
                    let number = Int(fullPath[numberRange])!
                    let baseName = String(fullPath[..<range.lowerBound])  // Extract base name before the parentheses

                    return constructUniqueName(startingFrom: number + 1,
                                               baseName: baseName.trimmingCharacters(in: .whitespaces),
                                               extensionPart: extensionPart,
                                               fileManager: fileManager,
                                               url: url)
                }
            }
        } catch {
            Log.error("Invalid regex: \(error.localizedDescription)")
        }

        // Default return if no number is found or if regex fails
        return constructUniqueName(startingFrom: 1,
                                   baseName: fullPath,
                                   extensionPart: extensionPart,
                                   fileManager: fileManager,
                                   url: url)
    }

    /// Constructs a unique filename by appending an incrementing number in 
    /// parentheses until a non-conflicting filename is found.
    ///
    /// - Parameters:
    ///   - number: The starting number to use for appending to the filename.
    ///   - baseName: The base name of the file without extension or number.
    ///   - extensionPart: The extension of the file, including the leading dot.
    ///   - fileManager: The file manager used to check file existence.
    ///   - url: The URL specifying the directory where the file will be located.
    /// - Returns: A unique filename as a `String` that does not conflict 
    ///            with existing files in the specified directory.
    private func constructUniqueName(startingFrom number: Int,
                                     baseName: String,
                                     extensionPart: String,
                                     fileManager: FileManager,
                                     url: URL) -> String {
        var counter = number
        var candidateName = "\(baseName) (\(counter))\(extensionPart)"
        let basePath = url.deletingLastPathComponent()

        // Generate names until a unique one is found
        while fileManager.fileExists(atPath: basePath.appendingPathComponent(candidateName).path) {
            counter += 1
            candidateName = "\(baseName) (\(counter))\(extensionPart)"
        }

        return candidateName
    }

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

        // Check if the computed URL actually points to a folder. If not, fall back to a default or handle the error.
        var isDirectory: ObjCBool = false
        let exists = FileManager.default.fileExists(atPath: folderURL.path,
                                                    isDirectory: &isDirectory)

        // If the path exists and is a directory, return it. Otherwise, handle the case where the path is not valid.
        if exists && isDirectory.boolValue {
            return folderURL
        } else {
            // Log the issue or handle it according to your application's error handling policy
            Log.warning("The computed nearest folder URL is not a valid directory: \(folderURL.path)")
            return FileManager.default.urls(for: .documentDirectory,
                                            in: .userDomainMask).first ?? folderURL
        }
    }

    /// Recursively creates missing directories up to the specified URL.
    /// - Parameters:
    ///   - url: The URL where directories need to be created.
    ///   - createSelf: Indicates whether the directory at the provided URL should also be created.
    /// - Throws: An error if the directories could not be created.
    private func createMissingParentDirectory(for url: URL, createSelf: Bool = true) throws {
        let parentDirectory = url.deletingLastPathComponent()

        if !FileItem.fileManger.fileExists(atPath: parentDirectory.path) {
            try createMissingParentDirectory(for: parentDirectory, createSelf: true)
        }

        if createSelf && !FileItem.fileManger.fileExists(atPath: url.path) {
            do {
                Log.info("Creating directory at \(url.debugDescription)")
                try FileItem.fileManger.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
            } catch {
                Log.error("Failed to create directory: \(error.localizedDescription)")
                throw error
            }
        }
    }
}
