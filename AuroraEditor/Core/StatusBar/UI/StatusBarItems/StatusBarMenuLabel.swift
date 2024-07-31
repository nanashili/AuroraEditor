//
//  StatusBarMenuLabel.swift
//  Aurora Editor
//
//  Created by Axel Zuziak on 24.04.2022.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

/// A view that displays Text with custom chevron up/down symbol
internal struct StatusBarMenuLabel: View {

    /// The text to display
    private let text: String

    /// Initialize with text and model
    /// 
    /// - Parameter text: The text to display
    internal init(_ text: String) {
        self.text = text
    }

    /// The view body
    internal var body: some View {
        Text(text + "  ")
            .font(.system(size: 11)) +
        Text(Image.customChevronUpChevronDown)
            .font(.system(size: 11))
    }
}
