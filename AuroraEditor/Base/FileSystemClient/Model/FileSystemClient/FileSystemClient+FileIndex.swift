//
//  FileSystemClient+FileIndex.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 20/4/24.
//  Copyright © 2023 Aurora Company. All rights reserved.
//
import Combine
import Foundation
import Darwin

enum FileSystemError: Error {
    case unableToOpenDirectory(URL)
    case failedToLoadDirectory(URL, Error)
}

extension FileSystemClient {

    /// Loads files from a specified URL into `FileItem`s, accounting for concurrency and ignored paths.
    /// - Parameter url: The URL of the directory to load the items of
    /// 
    /// - Returns: `[FileItem]` representing the contents of the directory
    func loadFiles(fromURL url: URL) throws -> [FileItem] {
        var items: [FileItem] = []
        guard let dir = opendir(url.path) else {
            let errorMessage = String(cString: strerror(errno))
            throw NSError(domain: "FileSystemClientError", code: 1001,
                          userInfo: [NSLocalizedDescriptionKey: "Unable to open directory at URL: \(url)"])
        }
        defer { closedir(dir) }

        while let entry = readdir(dir) {
            let dName = entry.pointee.d_name
            let fileName = withUnsafePointer(to: dName) { (ptr) -> String? in
                    // Convert to a pointer to CChar or UInt8
                let charPtr = UnsafeRawPointer(ptr).assumingMemoryBound(to: CChar.self)
                return String(validatingUTF8: charPtr)
            }

            guard let validFileName = fileName else {
                Log.warning("Failed to decode filename.")
                continue
            }

            if validFileName == "." || validFileName == ".." {
                continue
            }

            let itemURL = url.appendingPathComponent(validFileName)
            if entry.pointee.d_type == DT_DIR { // DT_DIR is the directory type
                do {
                    let subItems = try loadFiles(fromURL: itemURL)
                    items.append(FileItem(url: itemURL, children: subItems, fileSystemClient: nil))
                } catch {
                    Log.error("Failed to load directory \(itemURL): \(error)")
                    continue
                }
            } else if entry.pointee.d_type == DT_REG { // DT_REG is the regular file type
                items.append(FileItem(url: itemURL, children: nil, fileSystemClient: nil))
            }
        }
        return items
    }

    /// Recursively updates `FileItem` children to match the actual file system, adding or deleting as necessary.
    /// - Parameter fileItem: The `FileItem` to update
    /// - Returns: Boolean indicating if any changes were made
    /// Recursively updates `FileItem` children to match the actual file system, adding or deleting as necessary.
    func rebuildFiles(fromItem fileItem: FileItem,
                      event: DispatchSource.FileSystemEvent) throws -> Bool {
        var didChangeSomething = false

        // Fetch the actual directory children
        let directoryContentsUrls = try fetchDirectoryContents(fileItem: fileItem)
        let existingUrls = Set(directoryContentsUrls)

        // Handle deletions
        didChangeSomething = handleDeletions(for: fileItem,
                                             withExistingUrls: existingUrls) || didChangeSomething

        // Handle additions and updates
        didChangeSomething = handleAdditions(for: fileItem,
                                             withExistingUrls: existingUrls) || didChangeSomething

        // Recursive update for children
        for child in fileItem.children ?? [] {
            if child.isFolder { // swiftlint:disable:this for_where
                // Ensure recursive updates propagate down to all child folders
                let childDidChange = try rebuildFiles(fromItem: child, event: event)
                didChangeSomething = childDidChange || didChangeSomething
            }
        }

        return didChangeSomething
    }

    /// Fetches and returns the contents of a directory from a FileItem's URL, standardized.
    func fetchDirectoryContents(fileItem: FileItem) throws -> [URL] {
        var results = [URL]()
        guard let dir = opendir(fileItem.url.path) else {
            throw NSError(domain: NSPOSIXErrorDomain,
                          code: Int(errno),
                          userInfo: [NSLocalizedDescriptionKey: "Unable to open directory: \(fileItem.url.path)"])
        }
        defer { closedir(dir) }

        while let entry = readdir(dir) {
            guard let name = withUnsafePointer(to: &entry.pointee.d_name, {
                $0.withMemoryRebound(to: Int8.self, capacity: Int(NAME_MAX)) {
                    String(validatingUTF8: $0)
                }
            }), name != ".", name != ".." else {
                continue
            }

            let entryURL = fileItem.url.appendingPathComponent(name)
            var statInfo = stat()
            if stat(entryURL.path, &statInfo) == 0 {
                // Check if it's a directory or a regular file (S_IFDIR or S_IFREG)
                if (statInfo.st_mode & S_IFMT) == S_IFDIR || (statInfo.st_mode & S_IFMT) == S_IFREG {
                    results.append(entryURL.standardized)
                }
            }
        }

        return results
    }

    /// Handles the deletion of `FileItem` children that no longer exist in the file system.
    private func handleDeletions(for fileItem: FileItem,
                                 withExistingUrls existingUrls: Set<URL>) -> Bool {
        guard var children = fileItem.children else {
            return false // No children, no deletions
        }

        let indicesToRemove = children.enumerated()
            .filter { !existingUrls.contains($0.element.url.standardized) }
            .map { $0.offset }

        let didRemoveItems = !indicesToRemove.isEmpty

        // Remove items from the end to avoid shifting
        for index in indicesToRemove.reversed() {
            let removedChild = children.remove(at: index)
            flattenedFileItems.removeValue(forKey: removedChild.id)
        }

        // Update the children array only if changes were made
        if didRemoveItems {
            fileItem.children = children
        }

        return didRemoveItems
    }

    /// Handles the addition of new `FileItem` children based on the actual contents of the file system.
    private func handleAdditions(for fileItem: FileItem, // swiftlint:disable:this function_body_length
                                 withExistingUrls existingUrls: Set<URL>) -> Bool {
        guard var children = fileItem.children else {
            let addedItems = existingUrls
                .filter { !ignoredFilesAndFolders.contains($0.lastPathComponent) }
                .compactMap { existingUrl -> FileItem? in
                    var isDir: ObjCBool = false
                    guard fileManager.fileExists(atPath: existingUrl.path, isDirectory: &isDir) else {
                        return nil
                    }

                    let subItems: [FileItem]?
                    if isDir.boolValue {
                        do {
                            subItems = try loadFiles(fromURL: existingUrl)
                        } catch {
                            return nil
                        }
                    } else {
                        subItems = nil
                    }

                    let newFileItem = FileItem(url: existingUrl,
                                               children: subItems,
                                               fileSystemClient: self)
                    subItems?.forEach { $0.parent = newFileItem }
                    newFileItem.parent = fileItem
                    flattenedFileItems[newFileItem.id] = newFileItem

                    return newFileItem
                }

            fileItem.children = addedItems
            return !addedItems.isEmpty
        }

        let existingChildrenUrls = Set(children.map { $0.url.standardized })
        let newUrls = existingUrls.subtracting(existingChildrenUrls)

        let newChildren: [FileItem] = newUrls.compactMap { existingUrl -> FileItem? in
            var isDir: ObjCBool = false
            guard fileManager.fileExists(atPath: existingUrl.path, isDirectory: &isDir) else {
                return nil
            }

            let subItems: [FileItem]?
            if isDir.boolValue {
                do {
                    subItems = try loadFiles(fromURL: existingUrl)
                } catch {
                    return nil
                }
            } else {
                subItems = nil
            }

            let newFileItem = FileItem(url: existingUrl,
                                       children: subItems,
                                       fileSystemClient: self)
            subItems?.forEach { $0.parent = newFileItem }
            newFileItem.parent = fileItem

            return newFileItem
        }

        if !newChildren.isEmpty {
            children.append(contentsOf: newChildren)
            fileItem.children = children
        }

        return !newChildren.isEmpty
    }
}
