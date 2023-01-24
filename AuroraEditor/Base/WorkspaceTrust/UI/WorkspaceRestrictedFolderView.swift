//
//  WorkspaceRestrictedFolderView.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/12/18.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import SwiftUI

struct WorkspaceRestrictedFolderView: View {
    var body: some View {
        VStack {
            Text("Restricted Mode")
                .font(.title2)
                .fontWeight(.medium)
                .padding(.top, 10)

            VStack(alignment: .leading) {

                // swiftlint:disable:next line_length
                Text("If you do not trust authors of files in the current folder, \nthe following features will be disabled:")
                    .font(.system(size: 12))
                    .padding(.top, -5)
                    .padding(.bottom, 5)

                HStack {
                    Image(systemName: "exclamationmark.triangle")
                        .foregroundColor(.red)
                        .font(.system(size: 14))
                    Text("Task are not allowed to run")
                        .font(.system(size: 13))
                }
                .padding(.bottom, 5)

                HStack {
                    Image(systemName: "exclamationmark.triangle")
                        .foregroundColor(.red)
                        .font(.system(size: 14))
                    Text("Debugging is disabled")
                        .font(.system(size: 13))
                }
                .padding(.bottom, 5)

                HStack {
                    Image(systemName: "exclamationmark.triangle")
                        .foregroundColor(.red)
                        .font(.system(size: 14))
                    Text("Certain editor setting are not applied")
                        .font(.system(size: 13))
                }
                .padding(.bottom, 5)

                HStack {
                    Image(systemName: "exclamationmark.triangle")
                        .foregroundColor(.red)
                        .font(.system(size: 14))
                    Text("All extensions are disabled or have limited functionality")
                        .font(.system(size: 13))
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 10)
            .frame(width: 400)
        }
    }
}

struct WorkspaceRestrictedFolderView_Previews: PreviewProvider {
    static var previews: some View {
        WorkspaceRestrictedFolderView()
    }
}
