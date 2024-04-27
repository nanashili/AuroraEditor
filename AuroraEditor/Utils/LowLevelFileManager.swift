//
//  LowLevelFileManager.swift
//  Aurora Editor
//
//  Created by Tihan-Nico Paxton on 2024/04/23.
//  Copyright © 2024 Aurora Company. All rights reserved.
//

import Foundation
import AppKit

/// `LowLevelFileManager` provides low-level file manipulation functions.
/// It encapsulates direct file system interactions such as creating, deleting,
/// and copying files and directories, often utilizing system calls.
/// This class operates with direct paths and does not abstract filesystem interactions,
/// thus giving precise control over file management tasks.
class LowLevelFileManager {
    // MARK: - File Management Functions

    /// Checks if a file or directory exists at the specified path.
    /// - Parameter path: The path to the file or directory to check.
    /// - Returns: `true` if the file or directory exists, otherwise `false`.
    func fileExists(atPath path: String) -> Bool {
        var statInfo = stat()
        return stat(path, &statInfo) == 0
    }

    /// Creates a directory at the specified path with the given permissions.
    /// - Parameters:
    ///   - path: The path where the directory will be created.
    ///   - permissions: The file permissions to set for the new directory, defaulting to 0o777.
    /// - Note: If the directory cannot be created, an alert is shown with the error.
    func createDirectory(atPath path: String, permissions: mode_t = 0o777) {
        if mkdir(path, permissions) != 0 {
            let errorMessage = String(cString: strerror(errno))
            showAlert(message: "Error Creating Directory", informativeText: errorMessage)
        }
    }

    /// Creates a new file at the specified path with the given permissions.
    /// - Parameters:
    ///   - path: The path where the file will be created.
    ///   - permissions: The file permissions to set for the new file, defaulting to 0o644.
    /// - Note: If the file cannot be created, an alert is shown with the error.
    func createFile(atPath path: String, permissions: mode_t = 0o644) {
        let fileDescriptor = open(path, O_CREAT | O_WRONLY | O_EXCL, permissions)
        if fileDescriptor == -1 {
            let errorMessage = String(cString: strerror(errno))
            showAlert(message: "Error Creating File", informativeText: errorMessage)
        }
        close(fileDescriptor)
    }

    /// Removes a file at the specified path.
    /// - Parameter path: The path of the file to remove.
    /// - Note: If the file cannot be removed, an alert is shown with the error.
    func removeFile(atPath path: String) {
        if unlink(path) != 0 {
            let errorMessage = String(cString: strerror(errno))
            showAlert(message: "Error Deleting File", informativeText: errorMessage)
        }
    }

    /// Duplicates a file or directory at the given URL to a new location.
    /// - Parameter url: The URL of the item to duplicate.
    /// - Note: If duplication fails, an alert is shown.
    func duplicate(item url: URL) {
        let basePath = url.deletingLastPathComponent().path
        let uniqueFileName = generateUniqueFileName(for: url)
        let newFilePath = "\(basePath)/\(uniqueFileName)"

        if fileExists(atPath: url.path) {
            copyFile(fromPath: url.path, toPath: newFilePath)
        } else {
            showAlert(message: "Failed to Duplicate", informativeText: "File doesn't exist!")
        }
    }

    /// Moves or renames a file or directory from one path to another.
    /// - Parameters:
    ///   - srcPath: The current path of the item.
    ///   - dstPath: The new path for the item.
    /// - Returns: `true` if the move was successful, otherwise `false`.
    func moveItem(fromPath srcPath: String, toPath dstPath: String) -> Bool {
        return rename(srcPath, dstPath) == 0
    }

    /// Copies a file from the source path to the destination path.
    /// - Parameters:
    ///   - srcPath: The path of the source file.
    ///   - dstPath: The path where the file should be copied to.
    /// - Note: If copying fails, an alert is shown with details of the error.
    func copyFile(fromPath srcPath: String, toPath dstPath: String) {
        let inputFd = open(srcPath, O_RDONLY)
        defer { close(inputFd) }

        let outputFd = open(dstPath, O_WRONLY | O_CREAT | O_EXCL, S_IRUSR | S_IWUSR)
        defer { close(outputFd) }

        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: 1024)
        defer { buffer.deallocate() }

        while true {
            let bytesRead = read(inputFd, buffer, 1024)
            if bytesRead == 0 { break } // End of file
            if bytesRead == -1 {
                showAlert(message: "Error Reading Source File",
                          informativeText: "An error occurred while reading from the source file at \(srcPath).")
                return
            }
            if write(outputFd, buffer, bytesRead) == -1 {
                showAlert(message: "Error Writing Destination File",
                          informativeText: "An error occurred while writing to the destination file at \(dstPath).")
                return
            }
        }
    }

    /// Retrieves the size of a file at the specified path.
    /// - Parameter path: The path to the file whose size is to be determined.
    /// - Returns: The size of the file in bytes as an `Int64`, or `nil` if it cannot be determined.
    func fileSize(atPath path: String) -> Int64? {
        var statInfo = stat()
        if stat(path, &statInfo) == 0 {
            return Int64(statInfo.st_size)
        }
        return nil
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
                                     url: URL) -> String {
        var counter = number
        var candidateName = "\(baseName) (\(counter))\(extensionPart)"
        let basePath = url.deletingLastPathComponent()

        // Generate names until a unique one is found
        while fileExists(atPath: basePath.appendingPathComponent(candidateName).path) {
            counter += 1
            candidateName = "\(baseName) (\(counter))\(extensionPart)"
        }

        return candidateName
    }

    /// Displays an alert with a specific message and informative text.
    /// - Parameters:
    ///   - message: The title of the alert.
    ///   - informativeText: The detailed message text of the alert.
    func showAlert(message: String, informativeText: String) {
        let alert = NSAlert()
        alert.alertStyle = .warning
        alert.messageText = message
        alert.informativeText = informativeText
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
}
