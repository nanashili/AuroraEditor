//
//  WorkspaceTrustConfirmationDialog.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2023/01/02.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

struct WorkspaceTrustConfirmationDialog: View {

    @State
    private var currentUrl: String = "~/Documents/GitHub/auroraeditor.com"

    @State
    private var parentFolderName: String = "GitHub"

    @State
    private var trustGitAuthors: Bool = false

    @Environment(\.presentationMode)
    var presentationMode

    var body: some View {
        HStack(alignment: .top) {
            Image(systemName: "lock.trianglebadge.exclamationmark")
                .symbolRenderingMode(.multicolor)
                .font(.title)

            VStack(alignment: .leading) {
                Text("Do you trust the authors of the files in this folder?")
                    .font(.title3)
                    .fontWeight(.medium)
                // swiftlint:disable:next line_length
                Text("Aurora Editor provides features that may automatically execute files in this folder.\n\nIf you don't trust the authors of the files, we recommend to continue in restricted mode as the files may be malicious.\n\n[Learn more](https://auroraeditor.com/faq/workspace-trust) about Workspace Trust in the Aurora Editor docs.\n\n\n\(currentUrl)")
                    .font(.body)
                    .padding(.vertical)
                    .multilineTextAlignment(.leading)

                Toggle("Trust the authors of all files in the parent folder `\(parentFolderName)`",
                       isOn: $trustGitAuthors)
                .font(.body)
                .toggleStyle(.checkbox)
                .padding(.bottom)

                HStack {
                    Spacer()

                    Button {

                    } label: {
                        Text("Trust Authors")
                    }
                    .buttonStyle(.borderedProminent)

                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Text("Cancel")
                    }
                }
            }
            .padding(.leading)
        }
        .padding()
        .frame(width: 550)
    }
}

struct WorkspaceTrustConfirmationDialog_Previews: PreviewProvider {
    static var previews: some View {
        WorkspaceTrustConfirmationDialog()
    }
}
