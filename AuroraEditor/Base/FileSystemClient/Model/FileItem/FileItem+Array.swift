//
//  FileItem+Array.swift
//  Aurora Editor
//
//  Created by Lukas Pistrol on 17.03.22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

public extension Array where Element == FileSystemClient.FileItem {

    /// Sorts the elements in alphabetical order.
    /// 
    /// - Parameter foldersOnTop: if set to `true` folders will always be on top of files.
    /// 
    /// - Returns: A sorted array of ``FileSystemClient/FileSystemClient/FileItem``
    func sortItems(foldersOnTop: Bool) -> [FileItem] {
        return sorted {
            switch (foldersOnTop, $0.children != nil, $1.children != nil) {
            case (true, true, false): // If folders should be on top, $0 is a folder and $1 is not
                return true
            case (true, false, true): // If folders should be on top, $0 is not a folder and $1 is
                return false
            default: // If foldersOnTop is false, or both are folders or both are files, sort alphabetically
                return $0.fileName < $1.fileName
            }
        }
    }
}

public extension Array where Element: Hashable {
    /// Checks the difference between two given items.
    /// 
    /// - Parameter other: Other element
    /// 
    /// - Returns: symmetricDifference
    func difference(from other: [Element]) -> [Element] {
        let thisSet = Set(self)
        let otherSet = Set(other)
        return Array(thisSet.symmetricDifference(otherSet))
    }
}
