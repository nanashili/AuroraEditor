//
//  FileIcon.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/05/20.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

/// File icon
public enum FileIcon {
    public enum FileType: String, CaseIterable {
        // MARK: - Cases
        case json, js, css, jsx, swift, env, example, gitignore, png, jpg, jpeg, ico, svg,
             entitlements, plist, md, txt = "text", rtf, html, py, sh, LICENSE, java, h, m,
             vue, go, sum, mod, makefile, ts
    }

    // MARK: - Private Properties
    private static let iconMap: [FileType: String] = [
        .json: "curlybraces", .js: "curlybraces",
        .css: "number", .jsx: "atom", .swift: "swift",
        .env: "gearshape.fill", .example: "gearshape.fill",
        .gitignore: "arrow.triangle.branch",
        .png: "photo", .jpg: "photo", .jpeg: "photo", .ico: "photo",
        .svg: "square.fill.on.circle.fill",
        .entitlements: "checkmark.seal", .plist: "tablecells",
        .md: "doc.plaintext", .txt: "doc.plaintext", .rtf: "doc.plaintext",
        .html: "chevron.left.forwardslash.chevron.right",
        .py: "chevron.left.forwardslash.chevron.right",
        .sh: "chevron.left.forwardslash.chevron.right",
        .LICENSE: "key.fill", .java: "cup.and.saucer",
        .h: "h.square", .m: "m.square", .vue: "v.square",
        .go: "g.square", .sum: "s.square", .mod: "m.square",
        .makefile: "terminal", .ts: "curlybraces"
    ]

    private static let colorMap: [FileType: Color] = [
        .swift: .orange, .html: .orange,
        .java: .red,
        .js: Color("SidebarYellow"), .entitlements: Color("SidebarYellow"),
        .json: Color("SidebarYellow"), .LICENSE: Color("SidebarYellow"),
        .css: .blue, .ts: .blue, .jsx: .blue, .md: .blue, .py: .blue,
        .sh: .green,
        .vue: Color(red: 0.255, green: 0.722, blue: 0.514, opacity: 1.000),
        .h: Color(red: 0.667, green: 0.031, blue: 0.133, opacity: 1.000),
        .m: Color(red: 0.271, green: 0.106, blue: 0.525, opacity: 1.000),
        .go: Color(red: 0.02, green: 0.675, blue: 0.757, opacity: 1.0),
        .sum: Color(red: 0.925, green: 0.251, blue: 0.478, opacity: 1.0),
        .mod: Color(red: 0.925, green: 0.251, blue: 0.478, opacity: 1.0),
        .makefile: Color(red: 0.937, green: 0.325, blue: 0.314, opacity: 1.0)
    ]

    // MARK: - Public Methods
    /**
     Retrieves the corresponding file icon for the given file type.

     This function uses a static dictionary `iconMap` to look up the icon string associated 
     with the provided `FileType`. If no association is found, it returns the default value `"doc"`.

     - Parameter fileType: The `FileType` for which the file icon is requested.
     - Returns: A string representing the SF Symbol for the corresponding file type. 
                If no association is found, it returns `"doc"`.
     */
    public static func fileIcon(fileType: FileType) -> String {
        return iconMap[fileType] ?? "doc"
    }

    /**
     Retrieves the corresponding color for the given file type.

     This function uses a static dictionary `colorMap` to look up the color associated with the provided `FileType`.
     If no association is found, it returns the default value `.accentColor`.

     - Parameter fileType: The `FileType` for which the color is requested.
     - Returns: A `Color` instance representing the color for the corresponding file type. 
                If no association is found, it returns `.accentColor`.
     */
    public static func iconColor(fileType: FileType) -> Color {
        return colorMap[fileType] ?? .accentColor
    }
}
