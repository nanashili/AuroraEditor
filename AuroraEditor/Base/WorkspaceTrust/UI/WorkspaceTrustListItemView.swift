//
//  WorkspaceTrustListItemView.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/12/18.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import SwiftUI

struct WorkspaceTrustListItemView: View {

    @State
    var folderPath: String = "Users/nanashili/Documents"

    var body: some View {
        Text(folderPath)
    }
}

struct WorkspaceTrustListItemView_Previews: PreviewProvider {
    static var previews: some View {
        WorkspaceTrustListItemView()
    }
}
