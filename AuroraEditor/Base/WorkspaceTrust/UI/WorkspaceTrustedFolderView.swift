//
//  WorkspaceTrustedFolderView.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/12/18.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import SwiftUI

struct WorkspaceTrustedFolderView: View {
    var body: some View {
        VStack {
            Text("Trusted Mode")
                .font(.title2)
                .fontWeight(.medium)
                .padding(.top, 10)

            VStack(alignment: .leading) {
                Text("If you trust the authors of the files in the current folder, \nall features are enabled:")
                    .font(.system(size: 12))
                    .padding(.top, -5)
                    .padding(.bottom, 5)

                HStack {
                    Image(systemName: "checkmark")
                        .foregroundColor(.green)
                        .font(.system(size: 14))
                    Text("Task are allowed to run")
                        .font(.system(size: 13))
                }
                .padding(.bottom, 5)

                HStack {
                    Image(systemName: "checkmark")
                        .foregroundColor(.green)
                        .font(.system(size: 14))
                    Text("Debugging is enabled")
                        .font(.system(size: 13))
                }
                .padding(.bottom, 5)

                HStack {
                    Image(systemName: "checkmark")
                        .foregroundColor(.green)
                        .font(.system(size: 14))
                    Text("All editor setting are applied")
                        .font(.system(size: 13))
                }
                .padding(.bottom, 5)

                HStack {
                    Image(systemName: "checkmark")
                        .foregroundColor(.green)
                        .font(.system(size: 14))
                    Text("All extensions are functional")
                        .font(.system(size: 13))
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 10)
            .frame(width: 400)
        }
    }
}

struct WorkspaceTrustedFolderView_Previews: PreviewProvider {
    static var previews: some View {
        WorkspaceTrustedFolderView()
    }
}
