//
//  AuroraEditorSetupItemView.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/12/17.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import SwiftUI

struct AuroraEditorSetupItemView: View {

    @State
    var checked: Bool = false

    @State
    var image: String

    @State
    var itemName: String

    @State
    var size: String

    var body: some View {
        VStack {
            Toggle(isOn: $checked) {
                HStack(spacing: 10) {
                    if image == "source_control" {
                        Image("git.branch")
                            .foregroundColor(checked ? .accentColor : .gray)
                    } else {
                        Image(systemName: image)
                            .foregroundColor(checked ? .accentColor : .gray)
                    }
                    Text(itemName)
                    Spacer()
                    Text(size)
                }
            }
            Divider()
                .padding(.vertical, 5)
        }
    }
}
