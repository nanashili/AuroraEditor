//
//  NSImage.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2023/11/21.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation
import AppKit

extension NSImage {
    /// Resize image
    /// 
    /// - Parameter targetSize: target size
    /// 
    /// - Returns: resized image
    func resizing(to size: NSSize) -> NSImage {
        let newImage = NSImage(
            size: size
        )
        newImage.lockFocus()
        self.draw(
            in: NSRect(
                origin: .zero,
                size: size
            ),
            from: NSRect(
                origin: .zero,
                size: self.size
            ),
            operation: .sourceOver,
            fraction: 1.0
        )
        newImage.unlockFocus()
        return newImage
    }
}
