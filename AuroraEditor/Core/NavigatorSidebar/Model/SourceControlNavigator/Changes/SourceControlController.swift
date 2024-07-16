//
//  SourceControlController.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/08/10.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI
import OSLog

/// A `NSViewController` that displays the source control changes in the workspace.
final class SourceControlController: NSViewController {

    typealias Item = FileItem

    /// The scroll view that contains the outline view.
    private var scrollView: NSScrollView!

    /// The outline view that displays the source control changes.
    private var outlineView: NSOutlineView!

    /// The workspace document.
    var workspace: WorkspaceDocument?

    /// The icon color style for the items.
    var iconColor: FileIconStyle = .color

    /// The file extension visibility for the items.
    var fileExtensionVisibility: FileExtensionsVisibility = .showAll

    /// The file extensions that should be shown.
    var shownFileExtensions: FileExtensions = .default

    /// The file extensions that should be hidden.
    var hiddenFileExtensions: FileExtensions = .default

    /// The row height for the outline view.
    var rowHeight: Double = 22 {
        didSet {
            outlineView.rowHeight = rowHeight
            outlineView.reloadData()
        }
    }

    /// Logger
    let logger = Logger(subsystem: "com.auroraeditor", category: "Source Control Controller")

    /// Whether to send a selection update when the outline view selection changes.
    private var shouldSendSelectionUpdate: Bool = true

    /// Reload the data in the outline view.
    override func loadView() {
        guard let fileURL = workspace?.fileURL else {
            fatalError("No file url provided")
        }

        self.scrollView = NSScrollView()
        self.view = scrollView

        outlineView = NSOutlineView()
        outlineView.dataSource = self
        outlineView.delegate = self
        outlineView.autosaveExpandedItems = true
        outlineView.headerView = nil
        outlineView.menu = SourceControlMenu(
            sender: outlineView,
            workspaceURL: fileURL
        )
        outlineView.menu?.delegate = self

        let column = NSTableColumn(identifier: .init(rawValue: "SourceControlCell"))
        column.title = "Source Control"
        outlineView.addTableColumn(column)

        scrollView.documentView = outlineView
        scrollView.contentView.automaticallyAdjustsContentInsets = false
        scrollView.contentView.contentInsets = .init(top: 10, left: 0, bottom: 0, right: 0)
        scrollView.scrollerStyle = .overlay
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.autohidesScrollers = true
    }

    /// Initialize the controller.
    init() {
        super.init(nibName: nil, bundle: nil)
    }

    /// Initialize the controller.
    required init?(coder: NSCoder) {
        fatalError()
    }

    /// Get the appropriate color for the items icon depending on the users preferences.
    /// 
    /// - Parameter item: The `FileItem` to get the color for
    /// 
    /// - Returns: A `NSColor` for the given `FileItem`.
    private func color(for item: Item) -> NSColor {
        if item.children == nil && iconColor == .color {
            return NSColor(item.iconColor)
        } else {
            return .secondaryLabelColor
        }
    }
}

extension SourceControlController: NSOutlineViewDataSource {
    /// Get the number of children for a given item.
    ///
    /// - Parameters:
    ///   - outlineView: The outline view
    ///   - item: The item (ignored in this implementation as we're dealing with a flat list)
    ///
    /// - Returns: The number of children
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        return filteredFileItems.count
    }

    /// Get the child for a given index.
    ///
    /// - Parameters:
    ///   - outlineView: The outline view
    ///   - index: The index
    ///   - item: The item (ignored in this implementation as we're dealing with a flat list)
    ///
    /// - Returns: The child at the specified index
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        return filteredFileItems[index]
    }

    /// Computed property to filter file items
    private var filteredFileItems: [FileItem] {
        return workspace?.fileSystemClient?.model?.changed ?? []
    }

    /// Get the object for a given item.
    /// 
    /// - Parameter outlineView: The outline view
    /// - Parameter item: The item
    /// 
    /// - Returns: The object
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        if let item = item as? Item {
            return item.children != nil
        }
        return false
    }
}

extension SourceControlController: NSOutlineViewDelegate {
    /// Should show cell expansion for table column.
    /// 
    /// - Parameter outlineView: The outline view
    /// - Parameter tableColumn: The table column
    /// - Parameter item: The item
    /// 
    /// - Returns: Whether to show cell expansion
    func outlineView(_ outlineView: NSOutlineView,
                     shouldShowCellExpansionFor tableColumn: NSTableColumn?,
                     item: Any) -> Bool {
        true
    }

    /// Should show cell outline for table column.
    /// 
    /// - Parameter outlineView: The outline view
    /// - Parameter item: The item
    /// 
    /// - Returns: Whether to show cell outline
    func outlineView(_ outlineView: NSOutlineView, shouldShowOutlineCellForItem item: Any) -> Bool {
        true
    }

    /// Get the view for the table column.
    /// 
    /// - Parameter outlineView: The outline view
    /// - Parameter tableColumn: The table column
    /// - Parameter item: The item
    /// 
    /// - Returns: The view for the table column
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {

        guard let tableColumn = tableColumn else { return nil }

        let frameRect = NSRect(x: 0, y: 0, width: tableColumn.width, height: rowHeight)

        return SourceControlTableViewCell(
            frame: frameRect,
            item: item as? Item,
            versionControlModel: nil,
            workspace: nil
        )
    }

    /// Get the label for the outline view.
    /// 
    /// - Parameter item: The item
    /// 
    /// - Returns: The label for the outline view
    private func outlineViewLabel(for item: Item) -> String {
        switch fileExtensionVisibility {
        case .hideAll:
            return item.fileName(typeHidden: true)
        case .showAll:
            return item.fileName(typeHidden: false)
        case .showOnly:
            return item.fileName(typeHidden: !shownFileExtensions.extensions.contains(item.fileType.rawValue))
        case .hideOnly:
            return item.fileName(typeHidden: hiddenFileExtensions.extensions.contains(item.fileType.rawValue))
        }
    }

    /// Selection did change
    /// 
    /// - Parameter notification: notification
    func outlineViewSelectionDidChange(_ notification: Notification) {
        guard let outlineView = notification.object as? NSOutlineView else {
            return
        }

        let selectedIndex = outlineView.selectedRow

        guard let navigatorItem = outlineView.item(atRow: selectedIndex) as? Item else { return }

        if !navigatorItem.isFolder && shouldSendSelectionUpdate && navigatorItem.doesExist {
            workspace?.openTab(item: navigatorItem)
            self.logger.warning("Opened a new tab for: \(navigatorItem.url)")
        }
    }

    /// Get the height of a row in the outline view.
    /// 
    /// - Parameter outlineView: The outline view
    /// - Parameter item: The item
    /// 
    /// - Returns: The height of the row
    func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
        rowHeight // This can be changed to 20 to match Xcode's row height.
    }
}

extension SourceControlController: NSMenuDelegate {

    /// Once a menu gets requested by a `right click` setup the menu
    ///
    /// If the right click happened outside a row this will result in no menu being shown.
    /// 
    /// - Parameter menu: The menu that got requested
    func menuNeedsUpdate(_ menu: NSMenu) {
        let row = outlineView.clickedRow
        guard let menu = menu as? SourceControlMenu else { return }

        if row == -1 {
            menu.item = nil
        } else {
            if let item = outlineView.item(atRow: row) as? Item {
                menu.item = item
                menu.workspace = workspace
            } else {
                menu.item = nil
            }
        }
        menu.update()
    }
}
