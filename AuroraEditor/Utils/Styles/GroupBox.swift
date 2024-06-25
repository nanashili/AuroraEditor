//
//  GroupBox.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/08/18.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

/// Group box style
struct AEGroupBox: GroupBoxStyle {
    /// Make body
    /// 
    /// - Parameter configuration: configuration
    /// 
    /// - Returns: Custom GroupBox
    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading) {
            configuration.label
            configuration.content
        }
        .padding()
        .background(Color(.controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}
